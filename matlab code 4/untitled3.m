pwd

realtime_LSTM12('C:/ALL 2 1/test2 1','testcsvrealtime1')

function realtime_LSTM12(testFolder, csvFile)

    % เพิ่ม mosquitto ใน PATH และตั้งค่า MQTT
    setenv('PATH', [getenv('PATH') ':/usr/local/bin']);  broker = 'broker.emqx.io';  topic = 'mn/csi';

    % โหลดโมเดล LSTM
    S = load('C:\Users\AdminPDC\Desktop\matlab code 4\RNN_LSTM_Network_ALL_อ2_parallel.mat','RNN_LSTM_Network');
    net = S.RNN_LSTM_Network;

    % สร้าง header CSV ถ้ายังไม่มี
    if ~isfile(csvFile)
        fid = fopen(csvFile,'w');
        fprintf(fid,'DateTime,FileName,Prediction\n'); fclose(fid);
    end

    fprintf('Realtime watching folder "%s"...\n', testFolder);

    prevModTime     = 0;     % เก็บเวลาที่ไฟล์ถูกแก้ไขล่าสุด (datenum)
    prevOldestStamp = [];    % เก็บ timestamp แรกของรอบก่อนหน้า

    while true
        pause(1);  % ตรวจทุก 1 วินาที

        % อ่านไฟล์ในโฟลเดอร์ (สมมติมีไฟล์เดียวหรือสนใจเฉพาะไฟล์ล่าสุด)
        files = dir(fullfile(testFolder,'*.pcap'));
        if isempty(files)
            continue;
        end
        info = files(1);
        fpath = fullfile(testFolder, info.name);

        % เช็คว่ามีการอัปเดตไฟล์จริง ๆ (datenum เปลี่ยน)
        if info.datenum <= prevModTime
            continue;   % ยังไม่อัปเดต โปรดรอรอบถัดไป
        end
        % อัปเดตตัวแปรเก็บค่า modification
        prevModTime = info.datenum;

        % อ่าน timestamp (ms) และ denoisedMag
        try
            [timestamp, denoisedMag] = fileReaderv1(fpath);
        catch ME
            warning('อ่าน "%s" ผิดพลาด: %s', info.name, ME.message);
            continue;
        end

        % หาช่วงเวลา cross-file จากรอบก่อนหน้า
        currOldest = timestamp(1);
        currNewest = timestamp(end);
        if ~isempty(prevOldestStamp)
            durCross = (currNewest - prevOldestStamp) / 1000;  % ms->s
            if durCross >= 3
                % classify ถ้าครบ 3 วิ ข้ามไฟล์เก่าไปไฟล์ใหม่
                predLbl = classify(net, denoisedMag, 'MiniBatchSize', 32);
                tstr = string(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));

                % เขียนลง CSV
                fid = fopen(csvFile,'a');
                fprintf(fid,'%s,%s,%s\n', tstr, info.name, predLbl);
                fclose(fid);

                % ส่ง MQTT
                msg = sprintf('{"time":"%s","file":"%s","prediction":"%s"}', tstr, info.name, predLbl);
                system(sprintf('mosquitto_pub -h %s -t %s -m ''%s''', broker, topic, msg));
                fprintf('[%s] %s → %s\n', tstr, info.name, predLbl);
            end
        end
        % เก็บ timestamp แรกไว้เช็ครอบต่อไป
        prevOldestStamp = currOldest;
    end
end
