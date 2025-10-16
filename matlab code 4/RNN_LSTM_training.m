function result = RNN_LSTM_training()
    clear; clc;
    fclose('all');

    % ————— กำหนดพาธชุดข้อมูล —————
    trainDataPath      = 'C:\08-06-25 อ1/train';
    validationDataPath = 'C:\08-06-25 อ1/validation';
    % testDataPath       = 'C:\08-06-25 อ1/test';
    testDataPath       = 'C:\te..3st3';

    % ————— โหลดข้อมูล —————
    [trainSeq, trainLbl] = createLSTMDataSet(trainDataPath);
    [valSeq,   valLbl]   = createLSTMDataSet(validationDataPath);
    [testSeq,  testLbl]  = createLSTMDataSet(testDataPath);

    % (ถ้า createLSTMDataSet คืนเป็น string ให้แปลงเป็น categorical)
    trainLbl = categorical(trainLbl);
    valLbl   = categorical(valLbl);
    testLbl  = categorical(testLbl);

    % ————— เทรนโมเดล LSTM พร้อม validation —————
    trainedNet = RNN_LSTM(trainSeq, trainLbl, valSeq, valLbl);

    % บันทึก network ออกมาเป็นไฟล์ .mat
    RNN_LSTM_Network = trainedNet;
    save('RNN_LSTM_Network_ALL_อ2_parallel.mat', 'RNN_LSTM_Network');
    result = trainedNet;

    % ————— สร้าง prediction และ confusion matrix บน test set —————
    miniBatchSize = 32;
    predLabels = classify(trainedNet, testSeq, 'MiniBatchSize', miniBatchSize);

    % predLabels เป็น categorical อยู่แล้ว (classify คืนมาเป็น categorical)
    % testLbl แปลงเป็น categorical ข้างบนแล้ว
    % ————— ดึงชื่อชุดทดสอบ (test set name) —————
    [~, testSetName, ~] = fileparts(testDataPath);  % ถ้า testDataPath = 'C:/ALL 1/test1' จะได้ testSetName = 'test1'

    % ————— คำนวณความแม่นยำ —————
    acc = sum(predLabels == testLbl) / numel(testSeq);
    fprintf('Accuracy on test set ("%s"): %.2f%%\n', testSetName, acc * 100);

    % ————— plot confusion matrix แบบกราฟิก —————
    figure;
    plotconfusion(testLbl, predLabels);
    title(sprintf('Confusion Matrix ("%s") (plotconfusion)', testSetName));

    % ————— แสดง confusion matrix แบบตัวเลข —————
    [confMat, classOrder] = confusionmat(testLbl, predLabels);
    disp(['Confusion Matrix (', testSetName, ') (ตัวเลข)']);
    disp(array2table(confMat, 'VariableNames', cellstr(classOrder), 'RowNames', cellstr(classOrder)));

    % ————— plot confusion matrix อีกแบบด้วย confusionchart —————
    figure;
    confusionchart(testLbl, predLabels);
    title(sprintf('Confusion Matrix ("%s") (confusionchart)', testSetName));
end

