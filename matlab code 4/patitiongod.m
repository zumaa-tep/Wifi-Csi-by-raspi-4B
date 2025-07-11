%% ====== User parameters ======
rootDir   = 'C:\08-06-2025';          % โฟลเดอร์ต้นทาง
destRoot  = 'C:\08-06-25 อ1';         % โฟลเดอร์ปลายทาง (จะมี train/test/validation ข้างใน)
categories = {'fall','sit','stand','walk','empthy'};  % กลุ่มคลาส

% สัดส่วนแบ่ง
ratios = struct( ...
    'train',      0.70, ...
    'test',       0.20, ...
    'validation', 0.10  ...
);
%% ================================

% สร้างโฟลเดอร์ปลายทาง (train/test/validation) ถ้ายังไม่มี
trainDir = fullfile(destRoot,'train');
testDir  = fullfile(destRoot,'test');
valDir   = fullfile(destRoot,'validation');
if ~exist(trainDir,'dir'), mkdir(trainDir); end
if ~exist(testDir, 'dir'), mkdir(testDir);  end
if ~exist(valDir,  'dir'), mkdir(valDir);   end

% Loop ผ่านแต่ละ category แล้วคัดลอกไฟล์ลง 3 โฟลเดอร์รวมกัน
for iCat = 1:numel(categories)
    catName = categories{iCat};
    
    % 1) เก็บไฟล์ทั้งหมดของคลาสนี้ (recursive)
    files = getFilesRecursive(rootDir, catName);
    N     = numel(files);
    
    % 2) นับจำนวนแต่ละชุด
    nTrain = floor(ratios.train      * N);
    nTest  = floor(ratios.test       * N);
    nVal   = N - nTrain - nTest;
    
    % 3) คัดลอกไปยัง train/test/validation (ไม่มี subfolder ย่อย)
    copyFiles(files(1:nTrain),                trainDir);
    copyFiles(files(nTrain+1 : nTrain+nTest), testDir);
    copyFiles(files(nTrain+nTest+1 : end),    valDir);
    
    % 4) สรุปผลบน Command Window
    fprintf('Class %-6s : total=%3d | train=%3d | test=%3d | val=%3d\n', ...
        catName, N, nTrain, nTest, nVal);
end


%% ====== ฟังก์ชันช่วยเหลือ ======
function files = getFilesRecursive(folder, pattern)
    % คืน struct array โดยแต่ละ element มี .folder, .name, .fullpath
    entries = dir(folder);
    entries = entries(~ismember({entries.name},{'.','..'}));
    files   = repmat(struct('folder','','name','','fullpath',''),0,1);

    for k = 1:numel(entries)
        namek = entries(k).name;
        pathk = fullfile(folder, namek);
        if entries(k).isdir
            % ถ้าเป็นโฟลเดอร์ ให้ recurse ลงไป
            files = [files; getFilesRecursive(pathk, pattern)]; %#ok<AGROW>
        else
            % ถ้าเป็นไฟล์ เช็คชื่อว่าตรงคลาสหรือไม่
            if contains(namek, pattern, 'IgnoreCase', true)
                f.folder   = folder;
                f.name     = namek;
                f.fullpath = pathk;
                files(end+1) = f; %#ok<AGROW>
            end
        end
    end
end

function copyFiles(fileStruct, destFolder)
    % copy ไฟล์ทั้งหมดใน fileStruct ไปยังโฟลเดอร์ปลายทางเดียวกัน
    for j = 1:numel(fileStruct)
        src = fileStruct(j).fullpath;
        dst = fullfile(destFolder, fileStruct(j).name);
        copyfile(src, dst);
    end
end
