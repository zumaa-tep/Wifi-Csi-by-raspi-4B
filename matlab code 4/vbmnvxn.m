filename = 'C:/splitest_40MHz_Empthy2_lib_2905_00000_20250529182641.pcap'
% isfile(filename)
[timeStamp, denoisedMag] = fileReaderv1(filename)
timeStamp
% numpackets = 1500;
% [csi_buff,NFFT] = CSIReader(filename,numpackets)