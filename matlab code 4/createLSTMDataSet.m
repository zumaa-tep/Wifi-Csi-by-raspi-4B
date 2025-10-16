function [sequences, categorical_labels] = createLSTMDataSet(path)

    s = strcat(path) %to reach mat file from provided path
    data = dir(s);
    data = data(~ismember({data.name}, {'.', '..'}));%     files = shuffle(data, 500);
    seqData = cell(length(data), 1); % initialize the data array
    labels = strings(length(data), 1); % initialize the labels array
    tempClassMatrix = strings(length(data), 1);

    for i = 1:length(data);  %every files are iterated and their labels are extracted
        dataFilename=data(i).name; %extract filename of the each data file
        filepath = fullfile(path, dataFilename); % แนะนำแบบนี้
        [filename,name,ext] = fileparts(filepath); %extract filename and other information from its path for each data file
        fclose('all');
        i
       
    %reading each activity data from its filepath using read_bf_file that
    %is provided by used CSI Tool software
    try
        [timeStamp, denoisedMag] = fileReaderv1(filepath);
        if isempty(denoisedMag) || ...
            isequal(size(denoisedMag), [0 0]) || ...
            (iscell(denoisedMag) && isempty(denoisedMag{1})) || ...
            (iscell(denoisedMag) && isequal(size(denoisedMag{1}), [0 0]))
    warning("⚠️ ไฟล์ %s มีข้อมูล 0×0 → ลบออก", dataFilename);
    delete(filepath);
    continue;
end

    catch ME
        warning("❌ อ่านไฟล์ไม่ได้: %s\n📄 สาเหตุ: %s", filepath, ME.message);
        continue;  % ข้ามไฟล์นี้ไป
    end        
        
        fName = data(i).name; % the name of the data file
        
        s = strcat(path, fName);

        [filepath,filename,ext] = fileparts(s);
        [filepath,filename,ext] = fileparts(s);
        label = regexprep(filename,'[\d"]','');        
        labels(i,1) = label;
        seqData{i, 1} = normalize(transpose((denoisedMag)));

        if contains(label, 'walk')
            tempClassMatrix(i,1) = 'walk';
            labels(i) = 'walk';
        elseif contains(label, 'sitdown')
            tempClassMatrix(i,1) = 'sitdown';
            labels(i) = 'sitdown';
        elseif contains(label, 'sit')
            tempClassMatrix(i,1) = 'sit';
            labels(i) = 'sit';
        elseif contains(label, 'standup')
            tempClassMatrix(i,1) = 'standup';
            labels(i) = 'standup';
        elseif contains(label, 'stand')
            tempClassMatrix(i,1) = 'stand';
            labels(i) = 'stand';
        elseif contains(label, 'fall')
            tempClassMatrix(i,1) = 'fall';
            labels(i) = 'fall';
        elseif  contains(label,'empty','IgnoreCase',true) || contains(label,'empthy','IgnoreCase',true)
            tempClassMatrix(i,1) = 'empty';
            labels(i) = 'empty';
        else
            warning("⚠️ ไม่รู้จัก label จากไฟล์: %s", filename);
        end
        fprintf("🔎 label ที่ได้คือ: '%s'\n", label);

    end
    [sequences, labels] = shuffle(seqData, tempClassMatrix, 0);
     
     sequences=seqData;
categorical_labels = tempClassMatrix;
end
