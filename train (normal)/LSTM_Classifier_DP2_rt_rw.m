%% This train LSTM with piecewise dropping learning rate  and on Raw data after denoising
function [Prediction,LSTM_DP2] = LSTM_Classifier_DP2_rt_rw(Data_Train_LSTM,Labels_Train,Data_Test_LSTM,Labels_Test)
% initializing the input size of the data
inputSize = 104;

% initializing the number of hidden units
numHiddenUnits1 = 125;
numHiddenUnits2 = 100;
% number of classes
numClasses = 4  ;

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
maxEpochs = 40;
miniBatchSize = 32;

% initializing the training options 
options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.01,...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'SequenceLength','longest', ...
    'GradientThreshold',1,...
    'ExecutionEnvironment','auto',...
    'Plots','training-progress',...
    'Verbose',false);

% Converting the cell array into categorical array
Labels_Train = categorical(Labels_Train);

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
% analyzeNetwork(net)

LSTM_DP2 = confusionchart(Labels_Test,Prediction);
LSTM_DP2.Title ='LSTM-DP2-rt-piecewise-Demoised-rawData';
LSTM_DP2.RowSummary = 'row-normalized';
LSTM_DP2.ColumnSummary = 'column-normalized';

end