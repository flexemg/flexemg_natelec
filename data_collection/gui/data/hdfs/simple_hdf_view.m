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
    data = double(data(2:65,:)');
    data(data > 2^15) = data(data > 2^15) - 2^15;
    for i = 1:64
        data(:,i) = data(:,i) + i*40000;
    end
    figure(1)
    plot(data);
    pause()
end