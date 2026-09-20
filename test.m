folderPath = fullfile('citra_test_images', '1. Histogram Citra');
files = dir(fullfile(folderPath, '*.png'));

for k = 1:length(files)
    namaFile = files(k).name;
    fullPath = fullfile(folderPath, namaFile);

    img = imread(fullPath);
    if size(img,3) == 3
        imgGray = rgb2gray(img);
    else
        imgGray = img;
    end

    myHist = histogram(imgGray);   
    libHist = imhist(imgGray);

    cocok = isequal(myHist(:), libHist(:));
    fprintf('%s -> hasil compare = %d\n', namaFile, cocok);
end
