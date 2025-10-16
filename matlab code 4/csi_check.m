filename = 'Data8_Train/room/Red/EMPTY/R_EMPTY_001_P150_0001.pcap'
% isfile(filename)
[timeStamp, denoisedMag] = fileReaderv1(filename)

% numpackets = 1500;
% [csi_buff,NFFT] = CSIReader(filename,numpackets)