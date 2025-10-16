% --------- เริ่มต้น ---------
% 1. กำหนดโฟลเดอร์ต้นทาง (root ที่มีหลายโฟลเดอร์ย่อยอยู่ข้างใน)
rootFolder   = 'C:\ALL 3';             % แก้เป็น path ของคุณ
% 2. กำหนดโฟลเดอร์ปลายทางที่จะเก็บไฟล์ทั้งหมด
targetFolder = 'C:\ALL 3';        % โฟลเดอร์ใหม่ที่ต้องการรวมไฟล์ทั้งหมดไว้

% สร้างโฟลเดอร์ปลายทางถ้ายังไม่มี
if ~exist(targetFolder,'dir')
    mkdir(targetFolder);
end

% 3. ดึงรายชื่อไฟล์ทั้งหมดจากทุกซับโฟลเดอร์
%    ถ้า MATLAB รุ่นใหม่ (R2016b ขึ้นไป) รองรับ '**' ได้เลย
filePattern = fullfile(rootFolder, '**', '*.pcap');  
% ถ้าต้องการทุกชนิดไฟล์ให้ใช้ '*' แทน '*.pcap'
allFiles = dir(filePattern);

% 4. วนลูปย้าย (move) หรือคัดลอก (copy) ไฟล์มาไว้ที่ targetFolder
for k = 1:numel(allFiles)
    srcPath  = fullfile(allFiles(k).folder, allFiles(k).name);
    destPath = fullfile(targetFolder, allFiles(k).name);
    
    % ถ้าต้องการย้ายไฟล์ (ลบไฟล์ต้นทางออก)
    movefile(srcPath, destPath);
    
    % ถ้าต้องการคัดลอกไฟล์ (ไม่ลบต้นฉบับ) ให้ใช้บรรทัดนี้แทน
    % copyfile(srcPath, destPath);
end
% --------- สิ้นสุด ---------
