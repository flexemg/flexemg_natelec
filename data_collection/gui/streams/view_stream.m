close all
clear
clc

while 1
    [baseName, folder] = uigetfile('.hdf');
    if baseName == 0
        break
    end
    fullFileName = fullfile(folder, baseName);
    hdf = h5read(fullFileName,'/dataGroup/dataTable');
    data = hdf.out;
    crc = find(data(1,:) ~= 0);
    for i = 1:length(crc)
        data(:,crc(i)) = data(:,crc(i)-1);
    end
    emg = double(data(2:65,:)');
    acc = double(data(66:68,:)');
    emg(emg > 2^15) = emg(emg > 2^15) - 2^15;
%     for i = 1:64
%         emg(:,i) = emg(:,i) + i*40000;
%     end
    figure(1)
    plot(emg);
    pause()
end