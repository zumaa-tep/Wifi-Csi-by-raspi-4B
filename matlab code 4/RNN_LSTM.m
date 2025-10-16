% function trainedLSTM_network = RNN_LSTM(trainSequences, trainLabels,validationSequences, validationLabels)
% %parameters
% numClasses = 5;  %number of activities
% label_name = {'empty';'fall';'stand';'walk';'sit'}; 
% % label_name = {'fall';'stand';'walk';'sit'}; 
% classNames = categorical(label_name);
% initialLR      = 0.01;    % learning rate เริ่มต้น
% dropFactor     = 0.1;     % เมื่อถึงช่วงที่กำหนด จะลด lr ลงเป็น lr*dropFactor
% dropPeriod     = 10;      % ทุก ๆ 10 epoch ให้ลด lr 
% maxEpochs = 60; % ปรับทีหลัง EP 60
% miniBatchSize = 32; % การอ่านข้อมูลทีละ miniBatchSize 32 MB
% 
% % options = trainingOptions('adam', ...
% %      'InitialLearnRate', initialLR, ...
% %     'LearnRateSchedule','piecewise', ...
% %     'LearnRateDropFactor', dropFactor, ...
% %     'LearnRateDropPeriod', dropPeriod, ...
% %     'MaxEpochs',maxEpochs, ...
% %     'MiniBatchSize',miniBatchSize, ...
% %     'SequenceLength','shortest', ... % longest
% %     'GradientThreshold',1,...
% %     'ExecutionEnvironment',"auto",...
% %     'Plots','training-progress',... 
% %     'SequencePaddingDirection', 'right',...
% %     'ValidationFrequency', 10, ... % ความถี่การปรับค่า 50
% %     'ValidationData', {validationSequences, categorical(validationLabels)}, ... % 
% %     'Verbose',false);
% 
% options = trainingOptions('adam', ...
%     'MaxEpochs',maxEpochs, ...
%     'MiniBatchSize',miniBatchSize, ...
%     'InitialLearnRate',0.001,... % LR
%     'SequenceLength','shortest', ... % longest
%     'GradientThreshold',1,...
%     'ExecutionEnvironment',"auto",...
%     'Plots','training-progress',... 
%     'SequencePaddingDirection', 'right',...
%     'ValidationFrequency', 10, ... % ความถี่การปรับค่า 50
%     'ValidationData', {validationSequences, categorical(validationLabels)}, ... % 
%     'Verbose',false);
% 
%     validIdx = ~cellfun(@isempty, trainSequences) & ...
%            cellfun(@(x) all(size(x) > 0), trainSequences);
% 
%     labels = categorical(trainLabels);
%     XTrain = trainSequences
%     YTrain = labels
%     unique(trainLabels)
%     unique(validationLabels)
% 
% inputSize = 104
% numHiddenUnits1 = 125;
% numHiddenUnits2 = 100;
% layers = [ ...
%     sequenceInputLayer(inputSize)
%     lstmLayer(numHiddenUnits1,'OutputMode','sequence')
%     dropoutLayer(0.2)
%     lstmLayer(numHiddenUnits2,'OutputMode','last')
%     dropoutLayer(0.2)
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer];
% 
% %       layers = [ ...
% %           sequenceInputLayer(104)
% %           lstmLayer(numHiddenUnits1, 'OutputMode', 'last')
% %           dropoutLayer(0.2) % ปิดข้อมูลจาก layer ก่อนหน้า 
% %           fullyConnectedLayer(numClasses)
% %           softmaxLayer('Name', 'softmax')
% %           classificationLayer('Name', 'output','Classes', classNames)];
% %          options = trainingOptions('adam', 'Plots', 'training-progress');
%     trainedLSTM_network = trainNetwork(XTrain, YTrain, layers, options);
% 
% end

function trainedLSTM_network = RNN_LSTM(trainSequences, trainLabels, validationSequences, validationLabels)
% RNN_LSTM_parallel  เทรน LSTM ด้วยการกระจายงานไปยังหลาย CPU core พร้อมกำหนด batch size ให้มีหลาย iterations ต่อ epoch

%--- สร้าง parallel pool ให้ใช้ workers = จำนวน core จริง (override profile limit ถ้าจำเป็น)
if isempty(gcp('nocreate'))
    clusterObj = parcluster('local');
    availCores = feature('numcores');
    try
        parpool('local', availCores);
    catch ME
        if contains(ME.message, 'Too many workers')
            clusterObj.NumWorkers = availCores;
            saveProfile(clusterObj);
            parpool('local', availCores);
        else
            rethrow(ME);
        end
    end
end

%--- จำกัด thread ของ client process
numThreads = feature('numcores');
maxNumCompThreads(numThreads);
setenv('OMP_NUM_THREADS', num2str(numThreads));

%--- เลือก ExecutionEnvironment
execEnv = 'parallel';

%--- พารามิเตอร์ของโครงข่าย
inputSize       = 104;
numHiddenUnits1 = 125;
numHiddenUnits2 = 100;
labelNames      = {'empty','fall','stand','walk','sit'};
numClasses      = numel(labelNames);
initialLR       = 0.1;
maxEpochs       = 60;
sequencePadding = 'right';
validationFreq  = 1;

%--- เตรียมข้อมูล (กรอง sequence ว่าง)
validTrainIdx = ~cellfun(@isempty, trainSequences) & cellfun(@(x) all(size(x)>0), trainSequences);
XTrain = trainSequences(validTrainIdx);
YTrain = categorical(trainLabels(validTrainIdx), labelNames);

validValIdx = ~cellfun(@isempty, validationSequences) & cellfun(@(x) all(size(x)>0), validationSequences);
XVal = validationSequences(validValIdx);
YVal = categorical(validationLabels(validValIdx), labelNames);

%--- สร้างเลเยอร์ LSTM
layers = [
    sequenceInputLayer(inputSize,'Name','input')
    lstmLayer(numHiddenUnits1,'OutputMode','sequence','Name','lstm1')
    dropoutLayer(0.2,'Name','drop1')
    lstmLayer(numHiddenUnits2,'OutputMode','last','Name','lstm2')
    dropoutLayer(0.2,'Name','drop2')
    fullyConnectedLayer(numClasses,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','output')
];

%--- กำหนด mini-batch size เพื่อให้มีประมาณ 8 iterations ต่อ epoch
Ntrain = numel(XTrain);
itersPerEpoch = 1;
miniBatchSize = max(1, floor(Ntrain/itersPerEpoch));

%--- ตั้งค่า training options พร้อม piecewise LR และ early stopping
options = trainingOptions('adam', ...
    'ExecutionEnvironment',     execEnv, ...
    'InitialLearnRate',         initialLR, ...
    'LearnRateSchedule',        'piecewise', ...
    'LearnRateDropFactor',      0.5, ...
    'LearnRateDropPeriod',      10, ...
    'ValidationData',           {XVal, YVal}, ...
    'ValidationFrequency',      validationFreq, ...
    'ValidationPatience',       1000, ...
    'MaxEpochs',                maxEpochs, ...
    'MiniBatchSize',            miniBatchSize, ...
    'SequenceLength',           'shortest', ...
    'GradientThreshold',        1, ...
    'SequencePaddingDirection', sequencePadding, ...
    'Plots',                    'training-progress', ...
    'Verbose',                  false);

%--- เริ่มการฝึกเครือข่าย
trainedLSTM_network = trainNetwork(XTrain, YTrain, layers, options);
end

% i = [จำนวนเทรน / batchsize] * [epoch]
% i = 557/768 * 60
% 60 = 1*60