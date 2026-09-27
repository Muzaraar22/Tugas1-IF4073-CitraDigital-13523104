folderPath = fullfile('citra_test_images', '3. Kasus 2');
files = dir(fullfile(folderPath, '*.png'));
img = imread(fullfile(folderPath, files(4).name));

test = histogramEqualizationLightness(img);
testRGB = histogramEqualizationRGB(img);
lib = histeq(img, 256);


figure;
subplot(1,4,1); imshow(img); title('Asli');
subplot(1,4,2); imshow(test); title("test equalization L");
subplot(1,4,3); imshow(lib); title("histeq");
subplot(1,4,4); imshow(testRGB); title("test equalization RGB");


viewHistogram(img, 'original');
viewHistogram(test, 'enhacement equalization L');
viewHistogram(testRGB, 'enhacement equalization RGB');


selisih = double(test) - double(lib);
fprintf('selisih max = %d\n', max(abs(selisih(:))));