%% This run the Algo SVM, LSTM, LSTM_DP2, and Naive_Bayes with Random dividing the test and train data  set the percentage variable PD " this uses validation set"
% define folder "DataX" name in this file and SVM_Test.m 
clear
clc
tic
fclose('all');
numpackets = 150  % Define the packet size of .pcap
PD = 0.80;  % defining the Percentage of split
VDRatio=0.1; % 10 fold Cross validation

%% Empty Room Data
% making a directory of the EMPTY folder
EMPTY = dir('Train/Data8_Train/room/Red/EMPTY');  % Load Emptay files
delBlanks = setdiff({EMPTY.name},{'.','..'})      % delete the dir : entries
EMPTY = transpose(delBlanks)                      % Creat db only with .pcap files

nFile = length(EMPTY);% number of Experiment Files for Train
train_idx = sort(randperm(nFile,round(nFile*PD))); % calculate index for training files
test_idx = setxor(train_idx,1:nFile); % calculate index for Test files
filepath1 = EMPTY(train_idx,:)     % training indices
filepath1_Test_Empty = EMPTY(test_idx,:) ; % test indices

% counting the number of files
Number_Empty_Files = length(filepath1); %  number of Experiment Files for train
% initializing an empty matrix to save the empty data
Data_Empty = []; % matrix for SVM
Data_Train = {}; % Struc for LSTM, NB with Feature Matrix data
Data_VD_LSTM = {}; % Struc for LSTM validation
Data_Train_LSTM = {}; % Struc for LSTM CSI_Raw_Denoised without Feature Matrix
% initializing an empty variable for storing the labels for training data
% and validation data
Labels_Train = {};
LabelsValidation = {};
% making a loop to pick one file at one time
for i=1:Number_Empty_Files
i
filename = ['Train/Data8_Train/room/Red/EMPTY/' filepath1{i}];  %% Define this path here and in SVM_test.m file as well
% calling the CSIreader function to extract the packets data from the file
[csi_buff,NFFT] = CSIReader(filename,numpackets);
% calling the plotcsi function to plot the denoised data
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Train{i,1} = FeatureExtraction(pcacomponents);
Data_Train_LSTM{i,1} = output'; % Data_Train LSTM Raw
Data_Empty = [Data_Empty; FeatureExtraction(pcacomponents)]; % 14 features for SVM
Labels_Train{i} = 'Empty';
end
k = i;

vd_idx = sort(randperm(nFile,round(nFile*VDRatio))); % calculate index for validation files
vd_EMPTY = EMPTY(vd_idx,:)     % validation indices
Number_VD_EMPTY_Files = length(vd_EMPTY); %  number of Experiment Files for validation

for v=1:Number_VD_EMPTY_Files
    % fetching each file name
v
filename = ['Train/Data8_Train/room/Red/EMPTY/' vd_EMPTY{v}];
% calling the CSIreader function to extract the packets data from the file
[csi_buff,NFFT] = CSIReader(filename,numpackets);
% calling the plotcsi function to plot the denoised data
output_vd = plotcsi(csi_buff, NFFT, false);
Data_VD_LSTM{v,1} = output_vd'; % Data_Train LSTM Raw    
LabelsValidation{v} = 'Empty';
end
w = v;
%% Sit Data'
% making a directory of the SIT folder
SIT = dir('Train/Data8_Train/room/Red/SIT');  % org
delBlanks = setdiff({SIT.name},{'.','..'}) % delete the dir : entries
SIT = transpose(delBlanks)                  % Creat db only with .pcap files
% counting the number of files to split
nFile = length(SIT);% number of Experiment Files for Train
train_idx = sort(randperm(nFile,round(nFile*PD))); % calculate index for training files
test_idx = setxor(train_idx,1:nFile); % calculate index for Test files
filepath2 = SIT(train_idx,:)     % training indices
filepath2_Test_SIT = SIT(test_idx,:) ; % test indices

% counting the number of files in the folder
Number_Sit_Files = length(filepath2); % number of Experiment Files for train

% initilizing an empty matrix to save the packets data from each file
Data_Sit = []; % matrix for SVM
% Data_Sit_m = []; % matrix for SVM with moment upto 5th order
% % making a loop to pick one file at one time
for i=1:Number_Sit_Files
i
% fetching each file name one by one
filename = ['Train/Data8_Train/room/Red/SIT/' filepath2{i}];
% calling the CSIreader function to extract the packets data from the file
[csi_buff,NFFT] = CSIReader(filename,numpackets);
% calling the plotcsi function to plot the denoised data
output = plotcsi(csi_buff, NFFT, false);
% performing the PCA of the data of each file
pcacomponents = PCAcomponents(output);
% extracting 14 features of each file one by one and storing it rowise
Data_Sit = [Data_Sit; FeatureExtraction(pcacomponents)];
% Data_Sit_m = [Data_Sit_m; FeatureExtraction2(pcacomponents)];

Data_Train{i+k,1} = FeatureExtraction(pcacomponents);
% Data_Train_m{i+k,1} = FeatureExtraction2(pcacomponents);
Data_Train_LSTM{i+k,1} = output'; % Data_Train LSTM Raw
% giving each Features row a lable for example 2 or 'SIT' for empty data
% files
Labels_Train{i+k} = 'Sit';
end


l = i+k;

vd_idx = sort(randperm(nFile,round(nFile*VDRatio))); % calculate index for validation files
vd_SIT = SIT(vd_idx,:)     % validation indices
% counting the number of files
Number_VD_SIT_Files = length(vd_SIT); %  number of Experiment Files for validation

for v=1:Number_VD_SIT_Files
    % fetching each file name
v
filename = ['Train/Data8_Train/room/Red/SIT/' vd_SIT{v}];
% calling the CSIreader function to extract the packets data from the file
[csi_buff,NFFT] = CSIReader(filename,numpackets);
% calling the plotcsi function to plot the denoised data
output_vd = plotcsi(csi_buff, NFFT, false);
Data_VD_LSTM{v+w,1} = output_vd'; % Data_Train LSTM Raw    
LabelsValidation{v+w} = 'Sit';
end
x = v+w;

%% Stand Data
STAND = dir('Train/Data8_Train/room/Red/STAND');  % org
delBlanks = setdiff({STAND.name},{'.','..'}) % delete the dir entries
STAND = transpose(delBlanks)                  % Creat db only with .pcap files

% counting the number of files to split
nFile = length(STAND);% number of Experiment Files for Train
% PD = 0.8;  % defining the Percentage of split
train_idx = sort(randperm(nFile,round(nFile*PD))); % calculate index for training files
test_idx = setxor(train_idx,1:nFile); % calculate index for Test files
filepath3 = STAND(train_idx,:)     % training indices
filepath3_Test_STAND = STAND(test_idx,:) ; % test indices

Number_Stand_Files = length(filepath3); % number of Experiment Files for train
Data_Stand = []; % matrix for SVM
% Data_Stand_m = []; % matrix for SVM with moment upto 5th order
for i=1:Number_Stand_Files
i
filename = ['Train/Data8_Train/room/Red/STAND/' filepath3{i}];
[csi_buff,NFFT] = CSIReader(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Stand = [Data_Stand; FeatureExtraction(pcacomponents)];
% Data_Stand_m = [Data_Stand_m; FeatureExtraction2(pcacomponents)];

Data_Train{i+l,1} = FeatureExtraction(pcacomponents);
% Data_Train_m{i+l,1} = FeatureExtraction2(pcacomponents);
Data_Train_LSTM{i+l,1} = output'; % Data_Train LSTM Raw
Labels_Train{i+l} = 'Stand';
end


m = l+i;

vd_idx = sort(randperm(nFile,round(nFile*VDRatio))); % calculate index for validation files
vd_STAND = STAND(vd_idx,:)     % validation indices
% counting the number of files
Number_VD_STAND_Files = length(vd_STAND); %  number of Experiment Files for validation

for v=1:Number_VD_STAND_Files
    % fetching each file name
v
filename = ['Train/Data8_Train/room/Red/STAND/' vd_STAND{v}];
% calling the CSIreader function to extract the packets data from the file
[csi_buff,NFFT] = CSIReader(filename,numpackets);
% calling the plotcsi function to plot the denoised data
output_vd = plotcsi(csi_buff, NFFT, false);
Data_VD_LSTM{v+x,1} = output_vd'; % Data_Train LSTM Raw    
LabelsValidation{v+x} = 'Stand';
end
y = v+x;


%% Walk Data
WALK = dir('Train/Data8_Train/room/Red/WALK');  % org
delBlanks = setdiff({WALK.name},{'.','..'}) % delete the dir entries
WALK = transpose(delBlanks)                  % Creat db only with .pcap files

% counting the number of files to split
nFile = length(WALK);% number of Experiment Files for Train
% PD = 0.8;  % defining the Percentage of split
train_idx = sort(randperm(nFile,round(nFile*PD))); % calculate index for training files
test_idx = setxor(train_idx,1:nFile); % calculate index for Test files
filepath4 = WALK(train_idx,:)     % training indices
filepath4_Test_WALK = WALK(test_idx,:) ; % test indices
Number_Walk_Files = length(filepath4);% number of Experiment Files for train

Data_Walk = []; % matrix for SVM
% Data_Walk_m = []; % matrix for SVM with moment upto 5th order

for i=1:Number_Walk_Files
i
filename = ['Train/Data8_Train/room/Red/WALK/' filepath4{i}];
[csi_buff,NFFT] = CSIReader(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Walk = [Data_Walk; FeatureExtraction(pcacomponents)];
% Data_Walk_m = [Data_Walk_m; FeatureExtraction2(pcacomponents)];

Data_Train{i+m,1} = FeatureExtraction(pcacomponents);
% Data_Train_m{i+m,1} = FeatureExtraction2(pcacomponents);
Data_Train_LSTM{i+m,1} = output'; % Data_Train LSTM Raw
Labels_Train{i+m} = 'Walk';
end

f = i+m;

vd_idx = sort(randperm(nFile,round(nFile*VDRatio))); % calculate index for validation files
vd_WALK = WALK(vd_idx,:)     % validation indices
% counting the number of files
Number_VD_WALK_Files = length(vd_WALK); %  number of Experiment Files for validation

for v=1:Number_VD_WALK_Files
v
    % fetching each file name
filename = ['Train/Data8_Train/room/Red/WALK/' vd_WALK{v}];
% calling the CSIreader function to extract the packets data from the file
[csi_buff,NFFT] = CSIReader(filename,numpackets);
% calling the plotcsi function to plot the denoised data
output_vd = plotcsi(csi_buff, NFFT, false);
Data_VD_LSTM{v+y,1} = output_vd'; % Data_Train LSTM Raw    
LabelsValidation{v+y} = 'Walk';
end

o = y+v;

%% fall 
FALL = dir('Train/Data8_Train/room/Red/FALL/');  % org
delBlanks = setdiff({FALL.name},{'.','..'}) % delete the dir entries
FALL = transpose(delBlanks)                  % Creat db only with .pcap files

% counting the number of files to split
nFile = length(FALL);% number of Experiment Files for Train
% PD = 0.8;  % defining the Percentage of split
train_idx = sort(randperm(nFile,round(nFile*PD))); % calculate index for training files
test_idx = setxor(train_idx,1:nFile); % calculate index for Test files
filepath5 = FALL(train_idx,:)     % training indices
filepath5_Test_FALL = FALL(test_idx,:) ; % test indices
Number_Walk_Files = length(filepath5);% number of Experiment Files for train

Data_FALL = []; % matrix for SVM

for i=1:Number_Walk_Files
i
filename = ['Train/Data8_Train/room/Red/FALL/' filepath5{i}];
[csi_buff,NFFT] = CSIReader1(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_FALL = [Data_FALL; FeatureExtraction(pcacomponents)];
% Data_Walk_m = [Data_Walk_m; FeatureExtraction2(pcacomponents)];

Data_Train{i+f,1} = FeatureExtraction(pcacomponents);
% Data_Train_m{i+m,1} = FeatureExtraction2(pcacomponents);
Data_Train_LSTM{i+f,1} = output'; % Data_Train LSTM Raw
Labels_Train{i+f} = 'FALL';
end

vd_idx = sort(randperm(nFile,round(nFile*VDRatio))); % calculate index for validation files
vd_FALL = FALL(vd_idx,:);     % validation indices
% counting the number of files
Number_VD_FALL_Files = length(vd_FALL); %  number of Experiment Files for validation

for v=1:Number_VD_FALL_Files
v
filename = ['Train/Data8_Train/room/Red/FALL/' vd_FALL{v}];
[csi_buff,NFFT] = CSIReader1(filename,numpackets);
output_vd = plotcsi(csi_buff, NFFT, false);
Data_VD_LSTM{v+o,1} = output_vd'; % Data_Train LSTM Raw    
LabelsValidation{v+o} = 'FALL';
end

%% Lebels for train and Validation
Labels_Train = Labels_Train';
LabelsValidation = LabelsValidation';

%% Prepare test data files for TESTING LSTM, NB
tic
Number_Empty_Files = length(filepath1_Test_Empty);% number of Experiment Files for Test 
Data_Test = {}; % Test data with feature mat for LSTM and NB
% Data_Test_m = {}; % Struc for SVM, LSTM, NB with moment upto 5th order
Data_Test_LSTM = {}; % Raw Test data for LSTM
Labels_Test = {}; % label data with feature mat for LSTM and NB

% for EMPTY test file
for i=1:Number_Empty_Files
filename = ['Train/Data8_Train/room/Red/EMPTY/' filepath1_Test_Empty{i}];
[csi_buff,NFFT] = CSIReader(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Test{i,1} = FeatureExtraction(pcacomponents);
Data_Test_LSTM{i,1} = output'; % Raw Test data for LSTM
Labels_Test{i} = 'Empty';
end

k = i;

% % for SIT test file

Number_Sit_Files = length(filepath2_Test_SIT); % number of Experiment Files for Test 

for i=1:Number_Sit_Files
filename = ['Train/Data8_Train/room/Red/SIT/' filepath2_Test_SIT{i}];
[csi_buff,NFFT] = CSIReader(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Test{i+k,1} = FeatureExtraction(pcacomponents);
Data_Test_LSTM{i+k,1} = output'; % Raw Test data for LSTM
Labels_Test{i+k} = 'Sit';
end

l = i+k;

% % for STAND test file

Number_Stand_Files = length(filepath3_Test_STAND); % number of Experiment Files for Test 

for i=1:Number_Stand_Files
filename = ['Train/Data8_Train/room/Red/STAND/' filepath3_Test_STAND{i}];
[csi_buff,NFFT] = CSIReader(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Test{i+l,1} = FeatureExtraction(pcacomponents);
Data_Test_LSTM{i+l,1} = output'; % Raw Test data for LSTM
Labels_Test{i+l} = 'Stand';
end

m = l+i;

% % for Walk test file

Number_Walk_Files = length(filepath4_Test_WALK); % number of Experiment Files for Test 

for i=1:Number_Walk_Files
i
filename = ['Train/Data8_Train/room/Red/WALK/' filepath4_Test_WALK{i}];
[csi_buff,NFFT] = CSIReader(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Test{i+m,1} = FeatureExtraction(pcacomponents);
Data_Test_LSTM{i+m,1} = output'; % Raw Test data for LSTM
Labels_Test{i+m} = 'Walk';

end

s = m+i;

% % for Fall test file

Number_FALL_Files = length(filepath5_Test_FALL); % number of Experiment Files for Test 

for i=1:Number_FALL_Files
filename = ['Train/Data8_Train/room/Red/FALL/' filepath5_Test_FALL{i}];
[csi_buff,NFFT] = CSIReader1(filename,numpackets);
output = plotcsi(csi_buff, NFFT, false);
pcacomponents = PCAcomponents(output);
Data_Test{i+s,1} = FeatureExtraction(pcacomponents);
% Data_Test_m{i+m,1} = FeatureExtraction2(pcacomponents);
Data_Test_LSTM{i+s,1} = output'; % Raw Test data for LSTM
Labels_Test{i+s} = 'FALL';

end

Labels_Test = Labels_Test';

%% Train Data SVM
% making the final Dataset my merging the features matrix of each type of files
Data_Train_SVM = [Data_Empty; Data_Sit;Data_Stand; Data_Walk; Data_FALL];

Labels_Train_SVM = string(Labels_Train)';

[Data_Test_SVM,Labels_Test_SVM ] = SVM_Data(Data_Train_SVM, Labels_Train_SVM, filepath1_Test_Empty, numpackets ...
    , filepath2_Test_SIT, filepath3_Test_STAND, filepath4_Test_WALK,filepath5_Test_FALL ); %% ต้องแก้ตรงนี้

disp(size(Data_Train_SVM));
disp(size(Labels_Train));
%%  SVM with Optimized  # Final
[trainedClassifierSVM, validationAccuracy] = SVM_trainClassifier_Quard_Opt(Data_Train_SVM, Labels_Train)
SVMfit = trainedClassifierSVM.predictFcn(Data_Test_SVM)
figure;
confusion_matrix_SVM = confusionmat(Labels_Test_SVM,SVMfit);
% Visualizing the confusion matrix
SVM = confusionchart(confusion_matrix_SVM);
SVM.Title = 'SVM-OPT';
SVM.RowSummary = 'row-normalized';
SVM.ColumnSummary = 'column-normalized';

%%  Naive with Optimized  # Final
[trainedClassifierNB, validationAccuracy] = Naive_Bayes_Opt(Data_Train_SVM, Labels_Train)
NBfit = trainedClassifierNB.predictFcn(Data_Test_SVM)
figure;
confusion_matrix_NB = confusionmat(Labels_Test_SVM,NBfit);
% Visualizing the confusion matrix
NB = confusionchart(confusion_matrix_NB);
NB.Title = 'NaiveBayes-opt'
NB.RowSummary = 'row-normalized';
NB.ColumnSummary = 'column-normalized';