function result = denoise(matrixData)
    sizeSub = size(matrixData,2);
    rowNumbers = size(matrixData,1);
    csiDenoised = zeros([sizeSub, rowNumbers]);

    wname='db2'; %db2    %sym5
    level=4; %5 80,80,70 %4
    for i = 1 : 1 : sizeSub
        [c, l] = wavedec(matrixData(:,i),level,wname);
       fd = wden(matrixData(:,i), 'heursure','s', 'sln', level, wname); %lstm good
 
        csiDenoised(i,:)=fd;
    end
     figure
     plot(csiDenoised(:,3:4))
    result = csiDenoised;
end