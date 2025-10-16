% function realtime_LSTM1(testFolder, csvFile)

    % เพิ่ม mosquitto ใน PATH
    setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
    broker = 'broker.emqx.io';
    topic  = 'mn/csi';
    
    % โหลดโมเดล LSTM
    modelFile = 'C:\Users\AdminPDC\Desktop\matlab code 4/RNN_LSTM_Network_ALL_อ2_parallel.mat';
    S   = load(modelFile, 'RNN_LSTM_Network');
    net = S.RNN_LSTM_Network;
    
    % สร้าง header CSV ถ้ายังไม่มี
    if ~isfile(csvFile)
        fid = fopen(csvFile,'w');
        fprintf(fid, 'DateTime,FileName,Prediction\n');
        fclose(fid);
    end
    
    processed = {};    % รายชื่อไฟล์ที่ประมวลผลแล้ว
    windowDuration = seconds(3);  % ต้องสะสมข้อมูลไม่น้อยกว่า 3 วินาที

    fprintf('กำลังเฝ้าดูโฟลเดอร์ "%s" ทุกวินาที...\n', testFolder);
    
    while true
        bufferFiles = {};
        bufferData  = {};
        collectedDur = seconds(0);
        done = false;
        
        % เก็บไฟล์ใหม่ทุกวินาที จนครบเงื่อนไขทั้งสอง
        while ~done
            % รอ 1 วินาที
            pause(1);
            files = dir(fullfile(testFolder, '*.pcap'));
            names = {files.name};
            newNames = setdiff(names, [processed, bufferFiles]);
            for k = 1:numel(newNames)
                fname = newNames{k};
                fpath = fullfile(testFolder, fname);
                
                % อ่าน timestamp และ denoisedMag
                try
                    [timestamp, denoisedMag] = fileReaderv1(fpath);
                catch ME
                    warning('อ่าน "%s" ผิดพลาด: %s', fname, ME.message);
                    processed{end+1} = fname;
                    continue;
                end
                
                % คำนวณระยะเวลาจริงของ sequence (ms -> s)
                dur = (timestamp(end) - timestamp(1)) / 1000;
                collectedDur = collectedDur + seconds(dur);
                
                % อ่าน header file age (filesystem) เป็นวินาที
                info = dir(fpath);
                headerAge = (now - info.datenum) * 86400;
                
                % สะสมข้อมูล
                bufferFiles{end+1} = fname;
                bufferData{end+1}  = denoisedMag;
                
                % ถ้าสะสมครบ 3 วิ และ header file มีอายุมากกว่า 3 วิ
                if collectedDur >= windowDuration && headerAge >= 3
                    done = true;
                    break;
                end
            end
            if done
                break;
            end
        end
        
        % ถ้าไม่มีไฟล์ใหม่ ให้ลูปต่อไป
        if isempty(bufferFiles)
            continue;
        end
        
        % ประมวลผลข้อมูลใน buffer
        for i = 1:numel(bufferFiles)
            fname = bufferFiles{i};
            dataSeq = bufferData{i};
            
            predLbl = classify(net, dataSeq, 'MiniBatchSize', 32);
            nowStr = string(datetime("now", 'Format','yyyy-MM-dd HH:mm:ss'));
            
            % เขียนลง CSV
            fid = fopen(csvFile, 'a');
            fprintf(fid, '%s,%s,%s\n', nowStr, fname, predLbl);
            fclose(fid);
            
            % ส่ง MQTT
            jsonMsg = sprintf('{"time":"%s","file":"%s","prediction":"%s"}', nowStr, fname, predLbl);
            cmd = sprintf('mosquitto_pub -h %s -t %s -m ''%s''', broker, topic, jsonMsg);
            system(cmd);
            
            fprintf(" [%s] %s → %s\n", nowStr, fname, predLbl);
        end
        
        % ทำเครื่องหมายว่าไฟล์ใน buffer ได้ประมวลผลแล้ว
        processed = [processed, bufferFiles];
    end
end

