function [timeStamp, denoisedMag] = fileReaderv1(filename)
    % Read CSI data และคืนค่า magnitude ของ subcarriers (core 0) กับ timestamp
    CHIP = '43455c0';          % wifi chip (4339, 4358, 43455c0, 4366c0)
    BW = 40;                   % bandwidth (MHz)
    FILE = filename;           % path ของ pcap file
    NPKTS_MAX = 100000;        % จำนวน UDPs สูงสุดที่จะอ่าน
    HOFFSET = 16;              % header offset (bytes ก่อนเริ่มส่วน CSI)
    NFFT = BW * 3.2;           % ขนาด FFT (ตัวอย่าง: 40MHz -> 128 จุด)

    %% เปิด pcap
    p = readpcap();
    p.open(FILE);
    n = min(length(p.all()), NPKTS_MAX);
    [seconds, microseconds] = p.allFrames();
    % แปลง timestamp เป็นมิลลิวินาที ตั้งให้เริ่มต้นที่ 0
    sec_ms = cellfun(@double, seconds) * 1000;
    usec_ms = cellfun(@double, microseconds) / 1000;
    ts_all = sec_ms + usec_ms;
    ts_all = round(ts_all - ts_all(1));

    %% เตรียมเมทริกซ์เก็บ CSI magnitude core 0
    % ก่อน filter Null/Pilot เรายังเก็บ NFFT ค่าไว้
    rawMag_buffer = zeros(n, NFFT);
    timestamp1 = zeros(1, n);
    s1 = 1;

    %% อ่านทุกเฟรม (until n)
    p.from_start();
    k = 1;
    while k <= n
        f = p.next();
        if isempty(f)
            break;
        end

        % ตรวจขนาดแพ็กเก็ตก่อน: 
        if f.header.orig_len - (HOFFSET - 1)*4 ~= NFFT * 4
            k = k + 1;
            continue;
        end

        % อ่าน payload เต็มๆ
        payload = f.payload;

        % ตรวจขนาด payload (บางครั้งอุปกรณ์อาจไม่ตรง 271 byte)
        if size(payload,1) < (HOFFSET + NFFT - 1)
            k = k + 1;
            continue;
        end

        % หาตำแหน่ง core index (ถ้าอยากเก็บเฉพาะ core=0 ให้ใช้เงื่อนไขข้างล่าง)
        payload_uint8 = typecast(payload, 'uint8');
        sc = swapbytes(typecast(payload_uint8(55:56), 'uint16'));
        core = bitand(sc, 7);

        % ถ้าอยากเก็บเฉพาะ core 0 ให้ใช้ if core==0 แต่ถ้าอยากเก็บทุก core ก็ comment บรรทัดนี้
        if core ~= 0
            k = k + 1;
            continue;
        end

        % แปลง CSI raw (complex) จาก payload
        H = payload(HOFFSET : HOFFSET + NFFT - 1);
        if strcmp(CHIP, '4339') || strcmp(CHIP, '43455c0')
            Hout = typecast(H, 'int16');
        elseif strcmp(CHIP, '4358')
            Hout = unpack_float(int32(0), int32(NFFT), H);
        elseif strcmp(CHIP, '4366c0')
            Hout = unpack_float(int32(1), int32(NFFT), H);
        else
            error('Invalid CHIP specification');
        end

        % reshape ให้เป็น Nx2 จากนั้นแปลงเป็น complex
        Hout = reshape(Hout, 2, []).';
        cmplx = double(Hout(1:NFFT,1)) + 1j * double(Hout(1:NFFT,2));

        % เก็บเฉพาะ magnitude ลง buffer ชั่วคราว
        mag = abs(cmplx).';
        rawMag_buffer(s1, :) = mag;
        timestamp1(s1) = ts_all(k);
        s1 = s1 + 1;

        k = k + 1;
    end

    % ตัดแถวที่ไม่ได้ใช้ทิ้ง
    rawMag_buffer = rawMag_buffer(1:s1-1, :);
    timestamp1 = timestamp1(1:s1-1);

    %% ลบ Null + Pilot subcarriers
    % กำหนดดัชนีของ subcarrier ที่ต้องการตัดทิ้ง (1-based index)
    nullSub = [1 2 3 4 5 6 12 40 54 62 63 64 65 66 67 68 76 90 118 124 125 126 127 128]; %  1 2 3 4 5 6 12 40 54 62 63 64 65 66 67 68 76 90 118 124 125 126 127 128
    % ในตัวอย่างนี้ pilotSub ว่างอยู่ ถ้าต้องการลบ pilot เพิ่ม ให้กำหนดใน pilotSub
    pilotSub = [];
    removeSub = [nullSub, pilotSub];

    % ใช้ removerows เพื่อตัดคอลัมน์ที่กำหนด (transpose ก่อน-หลัง)
    rawMag  = removerows(rawMag_buffer.', 'ind', removeSub).';

    adj = 3;       % ขนาด window (จำนวนจุดซ้าย-ขวา) ใน Hampel
    nsig = 0.75;   % threshold (multiples ของ MAD) ใน Hampel
    denoisedMag = zeros(size(rawMag));
    for idx = 1:size(rawMag,1)
        % แค่ใช้ Hampel filter (ไม่มี wavelet)
        denoisedMag(idx,:) = hampel(rawMag(idx,:), adj, nsig);
    end
    % เซ็ต output
    timeStamp = timestamp1;
    % denoisedMag เป็นเมทริกซ์ขนาด [จำนวนเฟรม x (NFFT - numel(removeSub))]

    % ไม่ต้องแสดงกราฟใดๆ (comment ส่วน plotting ออก)
    % Plotting results
    % 1) Heatmap of CSI magnitude across subcarriers vs. time
    figure('Name','CSI Magnitude Heatmap','NumberTitle','off');
    imagesc(timeStamp, 1:size(denoisedMag,2), denoisedMag.');
    axis xy;
    xlabel('Time (ms)'); ylabel('Subcarrier Index');
    title('CSI Magnitude Heatmap (Core 0)');
    colorbar;

    % 2) Mean magnitude over time
    figure('Name','Mean CSI Magnitude','NumberTitle','off');
    plot(timeStamp, mean(denoisedMag,2));
    xlabel('Time (ms)'); ylabel('Mean Magnitude');
    title('Mean CSI Magnitude vs Time');

    % 3) 3D Surface plot
    [T, S] = meshgrid(timeStamp, 1:size(denoisedMag,2));
    Z = denoisedMag.';  % rows: subcarriers, cols: time
    figure('Name','3D CSI Surface','NumberTitle','off');
    surf(T, S, Z, 'EdgeColor','none');
    view(45, 30);
    xlabel('Time (ms)'); ylabel('Subcarrier Index'); zlabel('Magnitude');
    title('3D Surface of CSI Magnitude');
    colorbar;
    grid on;
end

% function [timeStamp, denoisedMag] = fileReaderv1(filename)
%     % Read CSI data และคืนค่า magnitude ของ subcarriers (core 0) กับ timestamp
%     CHIP = '43455c0';          % wifi chip (4339, 4358, 43455c0, 4366c0)
%     BW = 40;                   % bandwidth (MHz)
%     FILE = filename;           % path ของ pcap file
%     NPKTS_MAX = 150;        % จำนวน UDPs สูงสุดที่จะอ่าน
%     HOFFSET = 16;              % header offset (bytes ก่อนเริ่มส่วน CSI)
%     NFFT = BW * 3.2;           % ขนาด FFT (ตัวอย่าง: 40MHz -> 128 จุด)
% 
%     %% เปิด pcap
%     p = readpcap();
%     p.open(FILE);
%     n = min(length(p.all()), NPKTS_MAX);
%     [seconds, microseconds] = p.allFrames();
%     % แปลง timestamp เป็นมิลลิวินาที ตั้งให้เริ่มต้นที่ 0
%     sec_ms = cellfun(@double, seconds) * 1000;
%     usec_ms = cellfun(@double, microseconds) / 1000;
%     ts_all = sec_ms + usec_ms;
%     ts_all = round(ts_all - ts_all(1));
% 
%     %% เตรียมเมทริกซ์เก็บ CSI magnitude core 0
%     rawMag_buffer = zeros(n, NFFT);
%     timestamp1 = zeros(1, n);
%     s1 = 1;
% 
%     %% อ่านทุกเฟรม (until n)
%     p.from_start();
%     k = 1;
%     while k <= n
%         f = p.next();
%         if isempty(f), break; end
% 
%         % ตรวจขนาดแพ็กเก็ตก่อน
%         if f.header.orig_len - (HOFFSET - 1)*4 ~= NFFT * 4
%             k = k + 1;
%             continue;
%         end
% 
%         payload = f.payload;
%         if size(payload,1) < (HOFFSET + NFFT - 1)
%             k = k + 1;
%             continue;
%         end
% 
%         % หาตำแหน่ง core index
%         payload_uint8 = typecast(payload, 'uint8');
%         sc = swapbytes(typecast(payload_uint8(55:56), 'uint16'));
%         core = bitand(sc, 7);
%         if core ~= 0
%             k = k + 1;
%             continue;
%         end
% 
%         % แปลง CSI raw (complex)
%         H = payload(HOFFSET : HOFFSET + NFFT - 1);
%         if strcmp(CHIP, '4339') || strcmp(CHIP, '43455c0')
%             Hout = typecast(H, 'int16');
%         elseif strcmp(CHIP, '4358')
%             Hout = unpack_float(int32(0), int32(NFFT), H);
%         elseif strcmp(CHIP, '4366c0')
%             Hout = unpack_float(int32(1), int32(NFFT), H);
%         else
%             error('Invalid CHIP specification');
%         end
% 
%         Hout = reshape(Hout, 2, []).';
%         cmplx = double(Hout(1:NFFT,1)) + 1j * double(Hout(1:NFFT,2));
% 
%         % เก็บ magnitude ลง buffer
%         rawMag_buffer(s1, :) = abs(cmplx).';
%         timestamp1(s1) = ts_all(k);
%         s1 = s1 + 1;
%         k = k + 1;
%     end
% 
%     % ตัดแถวที่ไม่ได้ใช้
%     rawMag_buffer = rawMag_buffer(1:s1-1, :);
%     timestamp1 = timestamp1(1:s1-1);
% 
%     %% ลบ Null + Pilot subcarriers
%     % nullSub = [1 2 3 4 5 6 12 40 54 62 63 64 65 66 67 68 76 90 118 124 125 126 127 128];
%     nullSub = [1 2 3 4 5 40 59:72 125 126 127 128];
%     pilotSub = [];
%     removeSub = [nullSub, pilotSub];
%     rawMag = removerows(rawMag_buffer.', 'ind', removeSub).';
% 
%     % % %% พล็อตก่อน denoise
%     % % 1) Heatmap of raw CSI magnitude
%     % figure('Name','Raw CSI Magnitude Heatmap','NumberTitle','off');
%     % imagesc(timestamp1, 1:size(rawMag,2), rawMag.');
%     % axis xy;
%     % xlabel('Time (ms)'); ylabel('Subcarrier Index');
%     % title('Raw CSI Magnitude Heatmap (Core 0)');
%     % colorbar;
%     % 
%     % % 2) Mean raw magnitude over time
%     % figure('Name','Mean Raw CSI Magnitude','NumberTitle','off');
%     % plot(timestamp1, mean(rawMag,2));
%     % xlabel('Time (ms)'); ylabel('Mean Magnitude');
%     % title('Mean Raw CSI Magnitude vs Time');
% 
%     %% Denoise: Hampel filter
%     adj = 3; nsig = 0.75;
%     denoisedMag = zeros(size(rawMag));
%     for idx = 1:size(rawMag,1)
%         denoisedMag(idx,:) = hampel(rawMag(idx,:), adj, nsig);
%     end
%     denoisedMag = normalize(transpose((denoisedMag)));
% 
%     % เซ็ต output
%     timeStamp = timestamp1;
% 
%     %% พล็อตผลลัพธ์หลัง denoise
%     % 1) Heatmap of denoised CSI magnitude
%     figure('Name','Denoised CSI Magnitude Heatmap','NumberTitle','off');
%     imagesc(timeStamp, 1:size(denoisedMag,2), denoisedMag.');
%     axis xy;
%     xlabel('Time (ms)'); ylabel('Subcarrier Index');
%     title('Denoised CSI Magnitude Heatmap (Core 0)');
%     colorbar;
% 
%     % 2) Mean denoised magnitude over time
%     figure('Name','Mean Denoised CSI Magnitude','NumberTitle','off');
%     % plot(timeStamp, mean(denoisedMag,2));
%     xlabel('Time (ms)'); ylabel('Mean Magnitude');
%     title('Mean Denoised CSI Magnitude vs Time');
% 
%     % 3) 3D surface plot after denoise
%     [T, S] = meshgrid(timeStamp, 1:size(denoisedMag,2));
%     Z = denoisedMag.';
%     figure('Name','3D CSI Surface','NumberTitle','off');
%     surf(T, S, Z, 'EdgeColor','none');
%     view(45, 30);
%     xlabel('Time (ms)'); ylabel('Subcarrier Index'); zlabel('Magnitude');
%     title('3D Surface of Denoised CSI Magnitude');
%     colorbar;
%     grid on;
% end
