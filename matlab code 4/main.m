function main()
  % networkName = 'RNN_LSTM_Network';
  % trainDataPath = 'C:/csidata'; % train data path
  % validationDataPath = 'C:/validation';; % validation data path
  %testDataPath = 'C:/realdata/output_data/test/'; % test data path

% TRAINING DATA-SET
% select all files that end in '.mat' from the directory
  % [trainSequences, trainLabels] = createLSTMDataSet(trainDataPath);
  % [testSequences, testLabels] = createLSTMDataSet(validationDataPath);
% LSTM network is populated by train and validation data to train network
% and validation data is required to prevent overfitting
  % trainedNet = RNN_LSTMRNN_LSTM(trainSequences, trainLabels,validationSequences, validationLabels);
  % Input_Data_Folder = 'C:/';
  %        testData = testData();
  %         filename = 'C:/realdata';
  %         [timeStamp, denoisedMagTraining] = fileReader(filename);
  %         pc = pc(denoisedMagTraining);
  %         extractedFeautures = FeatureExtraction(pc, timeStamp);
  % 
  %     filename = 'C:/realdata/input_data/sitdown110.pcap';
  %     [timeStamp, denoisedMagTraining] = fileReader(filename);
  %     [pc, time] = pc(denoisedMagTraining, timeStamp);
  %     figure
  %     plot(rmoutliers(pc));
  %     figure
  %     plot(denoise(pc)) 
  %     trainDataPath = 'C:/output_data/train/'; % train data path
  % 
  %     [trainSequences, trainLabels] = createLSTMDataSet(trainDataPath);
  %     label_name = {'stand';'fall';'sitdown';'walk';'sit'; 'standup'};
  %     classNames = categorical(label_name);

% trainedNet = RNN_LSTM_training();
%% phase 2
muSit = zeros(1,1);
muStand = zeros(1,1);
muSitdown = zeros(1,1);
muStandUp = zeros(1,1);
muWalk = zeros(1,1);
muLie = zeros(1,1);
muFall = zeros(1,1);
numFeatures = 3; % ปรับตาม featrue extracion (result)

sigmaSit = zeros(1,1);
sigmaStand = zeros(1,1);
sigmaSitDown = zeros(1,1);
sigmaStandUp = zeros(1,1);
sigmaWalk = zeros(1,1);
sigmaLie = zeros(1,1);
sigmaFall = zeros(1,1);

sitMatrix = zeros(1,numFeatures);
standMatrix = zeros(1,numFeatures);
sitdownMatrix = zeros(1,numFeatures);
standupMatrix = zeros(1,numFeatures);
lieMatrix = zeros(1,numFeatures);
fallMatrix = zeros(1,numFeatures);
walkMatrix = zeros(1,numFeatures);

n1 = 0; n2 = 0; n3 = 0; n4 = 0; n5 = 0; n6 = 0; n7 = 0;

Input_Data_Folder='C:/csidata'; % folder path to access input data
s=strcat(Input_Data_Folder);
data = dir(s);
data = data(~ismember({data.name}, {'.', '..'}));% %Access input data folder and bring .dat files
for i = 1:length(data)
    dataFilename=data(i).name; %extract filename of the each data file
    filepath = fullfile(Input_Data_Folder, dataFilename); % แนะนำแบบนี้
    [filename,name,ext] = fileparts(filepath) ; %extract filename and other information from its path for each data file
    name = regexprep(name,'[\d"]','');
    i
 
    [tS, csiAmp] = fileReader(filepath);

    [pc, time] = PrincipalComponents(csiAmp, tS); 
    cleanPC = rmoutliers(pc.').';       
    features = FeatureExtraction(pc);

%––– STEP 4 : กระจายลงแต่ละ activity –––––––––––––––––––––––––––––––––––
    if name == "walk"
        n1 = n1 + 1;
        walkMatrix(n1,:) = reshape(features, [1, numFeatures]);
    elseif name == "fall"
        n2 = n2 + 1;
        fallMatrix(n2,:) = reshape(features, [1, numFeatures]);
    elseif name == "sit"
        n3 = n3 + 1;
       sitMatrix(n3,:) = reshape(features, [1, numFeatures]);
    elseif name == "sitdown"
        n4 = n4 + 1;
        sitdownMatrix(n4,:) = reshape(features, [1, numFeatures]);
    elseif name == "stand"
        n5 = n5 + 1;
       standMatrix(n5,:) = reshape(features, [1, numFeatures]);
    elseif name == "standup"
       n6 = n6 + 1;
        standupMatrix(n6,:) = reshape(features, [1, numFeatures]);
    elseif name == "lie"
       n7 = n7 + 1;
       lieMatrix(n7,:) = reshape(features, [1, numFeatures]);
    end
end

writematrix(walkMatrix, "walkMatrix.txt");
writematrix(sitMatrix, "sitMatrix.txt");
writematrix(sitdownMatrix, "sitdownMatrix.txt");
writematrix(standupMatrix, "standupMatrix.txt");
writematrix(fallMatrix, "fallMatrix.txt");
writematrix(standMatrix, "standMatrix.txt");

standMatrix = readmatrix("standMatrix.txt");
walkMatrix = readmatrix("walkMatrix.txt");
sitMatrix = readmatrix("sitMatrix.txt");
sitdownMatrix = readmatrix("sitdownMatrix.txt");
standupMatrix = readmatrix("standupMatrix.txt");
fallMatrix = readmatrix("fallMatrix.txt");
%% phase 3 เก่า

% n1 = size(walkMatrix,1);
% n2 = size(fallMatrix,1);
% n3 = size(sitMatrix,1);
% n4 = size(sitdownMatrix,1);
% n5 = size(standMatrix,1);
% n6 = size(standupMatrix,1);
% n7 = size(lieMatrix,1);
% 
% muWalk = mean(walkMatrix(:,[3,9]));
% muFall = mean(fallMatrix(:,[3,9]));
% muSit = mean(sitMatrix(:,[3,9]));
% muSitDown = mean(sitdownMatrix(:,[3,9]));
% muStand = mean(standMatrix(:,[3,9]));
% muStandUp = mean(standupMatrix(:,[3,9]));
% muLie = sum(lieMatrix)/n7;
% xxt= zeros(n1,14);
% for i = 1:n1
%  xxt = xxt + transpose(walkMatrix(i,:))*walkMatrix(i,:);
% end
% xxt = xxt/n1;
% sigma = xxt - transpose(muWalk)*muWalk+ 0.0001 *eye(size(muWalk,2));
% inverseS= inv(sigma);
% 
% sigmaSit = cov(sitMatrix(:,[3,9]));
% sigmaStand = cov(standMatrix(:,[3,9]));
% sigmaSitDown = cov(sitdownMatrix(:,[3,9]));
% sigmaStandUp = cov(standupMatrix(:,[3,9]));
% sigmaWalk = cov(walkMatrix(:,[3,9]));
% sigmaFall = cov(fallMatrix(:,[3,9]));
% 
% sigmaWalk2 = zeros(numFeatures,numFeatures);
% sigmaWalk3 = zeros(numFeatures,numFeatures);
% for i = 1 : size(walkMatrix,1)
%     sigmaWalk2 = sigmaWalk2 + (transpose(walkMatrix(i,:)-muWalk)*(walkMatrix(i,:)-muWalk));
%     sigmaWalk3 = sigmaWalk3 + transpose(walkMatrix(i,:))*walkMatrix(i,:)-transpose(muWalk)*(muWalk);
% end
% sigmaWalk2 = sigmaWalk2 / size(walkMatrix,1);
% sigmaWalk3 = sigmaWalk3 / size(walkMatrix,1);
% [sigma3,mu3] = robustcov(walkMatrix);
% sigmaStandUp = cov(standupMatrix);
% cov(walkMatrix) +0.0001 *eye(size(walkMatrix,2));
% e = eig(sigmaWalk)
% 
% sigmaLie = cov(lieMatrix);
% sigmaFall = cov(fallMatrix);
% tf = issymmetric(sigmaSit);
% energyValues = [sitdownMatrix(:,1), sitdownMatrix(:,4),sitdownMatrix(:,7),sitdownMatrix(:,10)];
% sigmaEn = cov(energyValues)*(n4/(n4-1));
% eig(sigmaEn)
% muEn = mean(energyValues);

%% PHASE 3 ── คำนวณ µ และ Σ สำหรับแต่ละท่า  (28 ฟีเจอร์เต็ม)

%-------------------------------------------------
% 1) จำนวนนับ sample
%-------------------------------------------------
nWalk     = size(walkMatrix    ,1);
nFall     = size(fallMatrix    ,1);
nSit      = size(sitMatrix     ,1);
nSitDown  = size(sitdownMatrix ,1);
nStand    = size(standMatrix   ,1);
nStandUp  = size(standupMatrix ,1);
nLie      = size(lieMatrix     ,1);

%-------------------------------------------------
% 2) ค่าเฉลี่ย (µ)  — ยาว 1×28
%-------------------------------------------------
muWalk     = mean(walkMatrix    ,1);
muFall     = mean(fallMatrix    ,1);
muSit      = mean(sitMatrix     ,1);
muSitDown  = mean(sitdownMatrix ,1);
muStand    = mean(standMatrix   ,1);
muStandUp  = mean(standupMatrix ,1);
muLie      = mean(lieMatrix     ,1);

%-------------------------------------------------
% 3) Covariance (Σ)  — ขนาด 28×28
%-------------------------------------------------
sigmaWalk     = cov(walkMatrix);
sigmaFall     = cov(fallMatrix);
sigmaSit      = cov(sitMatrix);
sigmaSitDown  = cov(sitdownMatrix);
sigmaStand    = cov(standMatrix);
sigmaStandUp  = cov(standupMatrix);
sigmaLie      = cov(lieMatrix);

% (เพิ่ม regularisation กันเมทริกซ์เอกภพ)
epsI = 1e-4 * eye(numFeatures);   % numFeatures = 28
sigmaWalk    = sigmaWalk    + epsI;
sigmaFall    = sigmaFall    + epsI;
sigmaSit     = sigmaSit     + epsI;
sigmaSitDown = sigmaSitDown + epsI;
sigmaStand   = sigmaStand   + epsI;
sigmaStandUp = sigmaStandUp + epsI;
sigmaLie     = sigmaLie     + epsI;

%-------------------------------------------------
% 4) ตัวอย่างคำนวณ inverse & eigen (ถ้าต้องใช้)
%-------------------------------------------------
invSigmaWalk = inv(sigmaWalk);
eWalk        = eig(sigmaWalk);

%-------------------------------------------------
% 5) “Energy 4 ช่อง” (คอลัมน์ 1 4 7 10) ใช้ต่อ PDF ตรวจ sit-down
%-------------------------------------------------
% energyValues = sitdownMatrix(:, [1 2 3 4]);     % N×4
% muEn   = mean(energyValues);
% sigmaEn = cov(energyValues) * (nSitDown/(nSitDown-1));   % unbiased

%-------------------------------------------------
% 6) robustcov (เลือกใช้เฉพาะที่จำเป็น)
%-------------------------------------------------
% [sigmaRobustWalk, muRobustWalk] = robustcov(walkMatrix);

%% phase 4
    % [data, features] = readTrainingData();
    % read test data
    % filename = 'C:/sitMatrix.txt';
    % activityMatrix = readmatrix(filename);
    % filename3 = 'C:/csidata/fall3.pcap';
    % [tStamp, csiMag] = fileReader(filename);
    % magxtime = [csiMag transpose(tStamp)];
    % cleaned = rmoutliers(magxtime);
    % denoisedMag = denoise(csiMag);
    % 
    % denoisedAmp = transpose(activityMatrix(:,1:256)); %
    % timeCleaned = transpose(activityMatrix(:,257)); 
    % 
    % [pc, time] = pc((denoisedAmp), timeCleaned);
    % y1 = denoisedAmp; %
    % 
    % principalComponent = pc; %
    % figure
    % plot(principalComponent(:,1));
    % hold on
    % plot(principalComponent(:,2));
    % hold off
    % 
    % figure
    % plot(principalComponent(:,1) + principalComponent(:,2));
    % x = transpose(timeStamp);
    % timeStamp = timeCleaned; %
    % % pcolor plot
    % x = transpose(1:size(denoisedMag,1));
    % y = 1:256;
    % normA = denoisedMag - min(denoisedMag(:))
    % normA = normA ./ max(normA(:)) 
    % pcolor(x,y,transpose(normA))
    % shading interp;
    % colormap(jet(256))
    % colorbar;   
    
%% Phase 4: เตรียมข้อมูลทดสอบและแสดงภาพ PCA + CSI Heatmap

% อ่านข้อมูลกิจกรรมจากไฟล์
% filename = 'A/sitMatrix.txt';
% activityMatrix = readmatrix(filename);

% อ่านไฟล์ CSI จาก .pcap
% isfile('Data/sit170.pcap')  
filename3 = 'fall3.pcap';
[tstamp, denoisedMag] = fileReader(filename3);
% numpackets = 3000;
% [tstamp, csimag] = CSIReader(filename3,numpackets);
tstamp
denoisedMag

% เตรียมข้อมูล PCA จากไฟล์ sitMatrix ที่อ่านไว้
% denoisedAmp = transpose(activityMatrix(:,10));
% timeCleaned = transpose(activityMatrix(:,10));

% ทำ PCA
[pc, time] = PrincipalComponents(denoisedMag, tstamp);

% % แสดง PCA องค์ประกอบที่ 1 และ 2
% figure
% plot(principalComponent(:,1)); hold on;
% plot(principalComponent(:,1)); hold off;
% 
% % แสดง PCA 1 + 2 รวมกัน
% figure
% plot(principalComponent(:,1) + principalComponent(:,2));
% อัปเดต timestamp ให้ตรง

timeStamp = time;
%% fhase 5 
y1 = [11 12 13 14 ;
      21 22 23 24 ;
      31 32 33 34 ];        % ตอนนี้ y1 มีขนาด 256×N
previousIndex = 1;
maxPDF  = -Inf;
sd = 0; su = 0;
lastLabel = "";

% nTimes = 1; 
for i = 1:size(denoisedMag,1) %หาตัว ts เริ่ม
    if(timeStamp(1,i) > 1)
        lastIndex = i % หาตัวเริ่ม
        break
    end
end 

% [pc, time] = PrincipalComponents(denoisedMag, timeStamp);
% figure
% plot(pc(:,1))
% hold on
% 
% plot(pc(:,2))
% hold off
% lastIndex = 1;

previousLabel = "walk";

modelFile = 'RNN_LSTM_Network.mat';     % ถ้าไฟล์อยู่โฟลเดอร์เดียวกับสคริปต์
S = load(modelFile);      
timeStamp
for i = 1:size(denoisedMag,2) 
    i 

    % if(timeStamp(1,i) > 10)
    %     fprintf('0') % เช็คตัวเริ่มว่ามันเกิน 10 ยัง
    
    % timeStamp(1,i)
    % timeStamp(1,lastIndex)

    if(timeStamp(1,i)- timeStamp(1,lastIndex) > 30 || i == size(denoisedMag,2)) % รับมา 3 วิ  
        % last index ต้องวิ่งขั้นตลอด X
        % เรียงใหม่ 1 = แถว = packet , 2 = คอลัมน์ = 256
        % timeStamp 1 = 1, 2 = packet

        lastIndex = i
        % nTimes = nTimes + 1;
        % subcarriers = denoisedMag(lastIndex:i,:);
        % subcarriers = normalize(subcarriers); % นำข้อมูลในตัวแปรปรับให้สเกลเดียว
        
        fprintf('1')
        size(timeStamp, 1)
        extractedWindow = pc(lastIndex:i,:); % pc เรียงขนานกับเวลา
        timeSt = transpose(timeStamp(:,lastIndex:i));
        window = [extractedWindow(:,1:10) timeSt]; 
        windowOutlier = rmoutliers(window(:,:)); % แยกหน้าต่างจากข้อมูลที่ช่วงมาได้
        
        % if(size(windowOutlier,1)<=15)
        %     break
        % end
        
        windowdenoised = (windowOutlier(:,1:9));
        
        % if previousLabel == "walk"|| previousLabel == "stand" 
        %     mylstmNetwork = S.RNN_LSTM_Network;
        %     fprintf('s')
        % elseif previousLabel == "sit"|| previousLabel == "sitdown"
        %     mylstmNetwork = S.RNN_LSTM_Network;
        % elseif previousLabel == "standup"
        %     mylstmNetwork = S.RNN_LSTM_Network;
        % else
            mylstmNetwork = S.RNN_LSTM_Network; 
        % end
        
        predLabels = classify(mylstmNetwork, (normalize(windowdenoised(:,lastIndex:i))), 'MiniBatchSize', 10);
        disp(predLabels) % คำตอบสมการ
        
        if previousLabel == "walk" && predLabels == "standup" % ใช้แก้ predlabels โดยใช้ท่าทั้งสองแบบในการช่วยหาท่าระหวา่งทาง
            predLabels = "sitdown"
        elseif previousLabel == "sit" && predLabels == "sitdown"
            predLabels = "standup"
        end
        
        % statisticalWindow = FeatureExtraction(windowdenoised, windowOutlier(:,11));
        statisticalWindow = FeatureExtraction(windowdenoised);
       
        if predLabels == "walk"
            y = mvnpdf(statisticalWindow(:,[3,9]),muWalk, sigmaWalk);
        elseif predLabels == "sit"
            y = mvnpdf(statisticalWindow(:,[3,9]),muSit,sigmaSit);
        elseif predLabels == "stand"
            y = mvnpdf(statisticalWindow(:,[3,9]),muStand,sigmaStand);
        elseif predLabel == "fall" && lastLabel == predLabel % เพื่อเช็คว่า fall ชัวร์
            y = mvnpdf(statisticalWindow(:,[3,9]),muFall,sigmaFall);
        elseif predLabel == "sitdown" % && lastLabel == predLabel
            y = mvnpdf(statisticalWindow(:,[3,9]),muSitDown,sigmaSitDown);
        elseif predLabel == "standup" % && lastLabel == predLabel 
            y = mvnpdf(statisticalWindow(:,[3,9]),muStandUp,sigmaStandUp);
        else % -----------------------------------------------------------
            lastIndex = previousIndex;
            break
        end        
                if y >= maxPDF
                    previousIndex = j;
                    if j == size(denoisedMag,2)
                       lastIndex = previousIndex; 
                       break
                    end
                    disp('activity continues')
                    continue
                    
                else
                    lastIndex = previousIndex;
                    fprintf('sasasass')
                    break;
                end
         extractedFeaturestimeSubWindow = featureExtraction(extractedWindow, time(lastIndex:j,:));
         extractedFeaturesSubWindowReshaped = reshape(extractedFeaturestimeSubWindow,[1,numFeatures]);
         energySubSubwindowValue = extractedFeaturesSubWindowReshaped(:,4)

         ySit = mvnpdf(extractedFeaturesSubWindowReshaped,muSit, sigmaSit);
         yWalk = mvnpdf(extractedFeaturesSubWindowReshaped,muWalk, sigmaWalk2);
         yStand = mvnpdf(extractedFeaturesSubWindowReshaped,muStand);
         ySitDown = mvnpdf(energySubSubwindowValue,muEn, sigmaEn);
         yStandUp = mvnpdf(vpa(sym(extractedFeaturesSubWindowReshaped)),muStandUp,sigmaStandUp);
         yFall = mvnpdf(vpa(sym(extractedFeaturesSubWindowReshaped)),muFall,sigmaFall);
         yLie = mvnpdf(vpa(sym(extractedFeaturesSubWindowReshaped)),muLie,sigmaLie);

         maxPDFSubWindow = ySitDown;

                if(maxPDFSubWindow < maxPDF) %% if after adding 0.5 sec pdf value of a new window is less than previous window => stop adding 0.5 sec 
                    finalWindowIndex = j;
                    figure
                    plot(extractedWindow)
                    fprintf('0')
                   break;
                end
                if(maxPDFSubWindow >= maxPDF) %% if after adding 0.5 sec pdf value of a new window is more than previous window => add again 0.5 sec
                    subwindowIndex = j;
                    finalWindowIndex = j;
                    maxPDF = maxPDFSubWindow;
                    fprintf('1')
                end
                figure
                plot(extractedWindow)
                
            end
        end

        % call lstm for data from i to finalWindowIndex
        % previousLabel = predLabels % เดี๋ยวจะมาแก้
    % end
end

%%
%     x = size(denoisedMag,1);
%     figure
%     plot(B(:,257),principalComponents(:,1));
%     hold on
%     plot(B(:,257),principalComponents(:,2));
%     hold off
%     denoised = detrend(denoisedMag);
%     figure
%     Y = fft(denoised, x);
%     Pyy = Y.*conj(Y)/x;
% f = 1000/x*(0:x);
% plot(f,Pyy(1:x+1))
% title('Power spectral density')
% xlabel('Frequency (Hz)')
%
% end 