%% This train LSTM with piecewise dropping learning rate and on Raw data after denoising along with Validation dataset

function [Prediction,LSTM_DP2] = LSTM_Classifier_DP2_rt_rw_vd(Data_Train_LSTM,Labels_Train,Data_Test_LSTM,Labels_Test,Data_VD_LSTM,LabelsValidation)
% initializing the input size of the data
% inputSize = 108;
    inputSize = 104;
% initializing the number of hidden units
numHiddenUnits1 = 125;
numHiddenUnits2 = 100;
% number of classes
numClasses = 5 ; %%% แก้ตรงนี้

layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits1,'OutputMode','sequence')
    dropoutLayer(0.2)
    lstmLayer(numHiddenUnits2,'OutputMode','last')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

% number of epochs
maxEpochs = 50;
miniBatchSize = 32;
validationFactor = 16;
% Converting the cell array into categorical array
LabelsValidation = categorical(LabelsValidation);
Labels_Train = categorical(Labels_Train);

numData = numel(Data_VD_LSTM);
numIterationsPerEpoch = floor(numData / validationFactor)*3;
% Data_VD_LSTM = cell2num(Data_VD_LSTM,2);
% initializing the training options 
options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01,...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    "LearnRateDropPeriod",10, ...
    'SequenceLength','longest', ...
    'GradientThreshold',1,...
    'ValidationData',{Data_VD_LSTM,LabelsValidation}, ...
    'ValidationFrequency',numIterationsPerEpoch, ...
    'ExecutionEnvironment','auto',...
    'Plots','training-progress',...
    'Verbose',false);

% training the network
net = trainNetwork(Data_Train_LSTM,Labels_Train,layers,options);

% predicting the class
Prediction = classify(net,Data_Test_LSTM, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');
% Converting the cell array into categorical array
Labels_Test = categorical(Labels_Test);

% computing the confusion matrix and visualizing it along with networkanalsys
figure
analyzeNetwork(net)

LSTM_DP2 = confusionchart(Labels_Test,Prediction);
LSTM_DP2.Title ='LSTM-DP2-rt-piecewise-Denoised-RawData-VD';
LSTM_DP2.RowSummary = 'row-normalized';
LSTM_DP2.ColumnSummary = 'column-normalized';

end