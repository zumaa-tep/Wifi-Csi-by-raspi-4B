function test_LSTM(testDataPath)

    fclose('all');

    modelFiles = { ...
        'RNN_LSTM_Network_ALL_อ2_parallel.mat', ...
         % 'RNN_LSTM_Network_ALL2_1.mat', ...
         % 'RNN_LSTM_Network_ALL2_2.mat', ...
         % 'RNN_LSTM_Network_ALL2_1,2.mat', ...
         % 'RNN_LSTM_Network_ALL_3.mat'  ...
    };

    numModels = numel(modelFiles);

    % ————— โหลด test data จากโฟลเดอร์ที่ส่งมา —————
    % fileReaderv1 จะคืนค่า sequences 
    [ ~ , testSeq ] = fileReaderv1(testDataPath);

    % แปลง Label เป็น categorical เสมอ เพื่อให้ compare กับผลทำนายได้
    % testLbl = categorical(testLblRaw);

    % ————— ตั้งค่า MiniBatchSize —————
    miniBatchSize = 32;  

    % ————— วนลูปโหลดและทดสอบแต่ละโมเดล —————
    for iModel = 1:numModels
        modelName = modelFiles{iModel};

        % ————— โหลดโมเดล —————
        if ~isfile(modelName)
            warning('ไม่พบไฟล์โมเดล: %s (ข้ามโมเดลตัวที่ %d)\n', modelName, iModel);
            continue;
        end

        % สมมติภายในไฟล์นี้มีตัวแปรชื่อ RNN_LSTM_Network
        loadedData = load(modelName, 'RNN_LSTM_Network');
        if ~isfield(loadedData, 'RNN_LSTM_Network')
            warning('ไฟล์ %s ไม่มีตัวแปร RNN_LSTM_Network (ข้าม)\n', modelName);
            continue;
        end
        trainedNet = loadedData.RNN_LSTM_Network;

        % ————— ทำการทำนาย (Classification) —————
        predLabels = classify(trainedNet, testSeq, 'MiniBatchSize', miniBatchSize)
    end
end
