% --------- เริ่มสคริปต์ ---------
% 1. กำหนดพาธโฟลเดอร์ต้นทาง (ให้เปลี่ยนเป็นโฟลเดอร์ของคุณ)
srcFolder = 'C:/ALL 11 2';

% 2. สร้างชื่อโฟลเดอร์ย่อย train, validation, และ test
trainFolder = fullfile(srcFolder, 'train11 2');
valFolder   = fullfile(srcFolder, 'validation11 2');
testFolder  = fullfile(srcFolder, 'test11 2');

if ~exist(trainFolder, 'dir')
    mkdir(trainFolder);
end
if ~exist(valFolder, 'dir')
    mkdir(valFolder);
end
if ~exist(testFolder, 'dir')
    mkdir(testFolder);
end

% 3. ดึงรายชื่อไฟล์ทั้งหมดในโฟลเดอร์ต้นทาง (ไม่รวมโฟลเดอร์ย่อย)
files = dir(fullfile(srcFolder, '*.pcap'));  
% ตรวจสอบว่าจริง ๆ รายการนี้มีแต่ไฟล์ .pcap ที่ยังไม่ย้าย

% 4. สุ่มลำดับไฟล์ แล้วคำนวณสัดส่วนสำหรับ test (20%) validation (10%) train (70%)
N     = numel(files);
idx   = randperm(N);                        % สุ่มลำดับ index ของไฟล์ 1:N

Ntest = round(0.20 * N);                    % 20% สำหรับ test
Nval  = round(0.10 * N);                    % 10% สำหรับ validation
% กรณีค่าจำนวนเต็มไม่ลงตัว ให้ถือว่าทดสอบ (test) ก่อน validation แล้ว train รับเอาที่เหลือ

testIdx = idx(1 : Ntest);                   % ดัชนีชุด test
valIdx  = idx(Ntest+1 : Ntest+Nval);        % ดัชนีชุด validation
trainIdx = idx(Ntest+Nval+1 : end);         % ดัชนีที่เหลือเป็นชุด train

% 5. ย้ายไฟล์ไปเก็บในโฟลเดอร์ test / validation / train ตามลำดับ
%    ถ้าต้องการคัดลอกแทนการย้าย ให้ใช้ copyfile แทน movefile

% -- ย้ายไป test (20%)
for ii = 1 : numel(testIdx)
    oldName = files(testIdx(ii)).name;
    oldPath = fullfile(srcFolder, oldName);
    newPath = fullfile(testFolder, oldName);
    movefile(oldPath, newPath);
end

% -- ย้ายไป validation (10%)
for ii = 1 : numel(valIdx)
    oldName = files(valIdx(ii)).name;
    oldPath = fullfile(srcFolder, oldName);
    newPath = fullfile(valFolder, oldName);
    movefile(oldPath, newPath);
end

% -- ย้ายที่เหลือไป train (70%)
for ii = 1 : numel(trainIdx)
    oldName = files(trainIdx(ii)).name;
    oldPath = fullfile(srcFolder, oldName);
    newPath = fullfile(trainFolder, oldName);
    movefile(oldPath, newPath);
end

% --------- เสร็จสิ้น ---------
