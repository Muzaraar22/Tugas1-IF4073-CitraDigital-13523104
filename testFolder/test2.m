imgSumber = imread(fullfile('citra_test_images','2. Kasus 1','image_01.png'));
imgReferensi = imread(fullfile('citra_test_images','2. Kasus 1','image_02.png'));

test = histogramSpecification(imgSumber, imgReferensi);
lib = imhistmatch(imgSumber, imgReferensi, 256); 

figure;
subplot(1,3,1); imshow(imgSumber);    title('Sumber');
subplot(1,3,2); imshow(imgReferensi); title('Referensi');
subplot(1,3,3); imshow(test); title('Hasil');

viewHistogram(imgSumber, 'Sumber');
viewHistogram(imgReferensi, 'Referensi');
viewHistogram(test, 'Hasil');