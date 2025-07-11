% 1) Point to the correct file
filename = 'C:/splitest_40_empthy_1_00000_20250609193537.pcap';  

% 2) (Optional) sanity-check
if exist(filename,'file')~=2
    error('File "%s" not found. Make sure the extension is ".pcap" and the path is correct.', filename);
end
if exist('fileReaderv1','file')~=2
    error('Cannot find fileReaderv1.m. Add its folder to the MATLAB path.');
end

% 3) Call the reader
[timeStamp, denoisedMag] = fileReaderv1(filename);

% filename = 'C:/stand 11 2 (191).pcap';  
% 
% % 2) (Optional) sanity-check
% if exist(filename,'file')~=2
%     error('File "%s" not found. Make sure the extension is ".pcap" and the path is correct.', filename);
% end
% if exist('fileReaderv1','file')~=2
%     error('Cannot find fileReaderv1.m. Add its folder to the MATLAB path.');
% end
% 
% % 3) Call the reader
% [timeStamp1, denoisedMag1] = fileReaderv1(filename);
% denoisedMag1
% filename = 'C:/sit 11 2 (112).pcap';  
% 
% % 2) (Optional) sanity-check
% if exist(filename,'file')~=2
%     error('File "%s" not found. Make sure the extension is ".pcap" and the path is correct.', filename);
% end
% if exist('fileReaderv1','file')~=2
%     error('Cannot find fileReaderv1.m. Add its folder to the MATLAB path.');
% end
% 
% % 3) Call the reader
% [timeStamp2, denoisedMag2] = fileReaderv1(filename);
% denoisedMag2