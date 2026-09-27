folderPath = fullfile('citra_test_images_final', '2. Kasus 1');
files = dir(fullfile(folderPath, '*.png'));

for k = 1:length(files)
    namaFile = files(k).name;
    fullPath = fullfile(folderPath, namaFile);
    img = imread(fullPath);

    viewHistogram(img, namaFile);
end

