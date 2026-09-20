img = imread(fullfile('citra_test_images','2. Kasus 1','image_01.png'));
if size(img,3) == 3, imgGray = rgb2gray(img); else, imgGray = img; end

hasil1 = intensityTransform(imgGray, 'negative', []);
hasil2 = intensityTransform(imgGray, 'log', []);         
hasil3 = intensityTransform(imgGray, 'power', [1 0.5]);  
hasil4 = intensityTransform(imgGray, 'stretch', [30 180]);

figure;
subplot(2,2,1); imshow(hasil1); title('Negative');
subplot(2,2,2); imshow(hasil2); title('Log');
subplot(2,2,3); imshow(hasil3); title('Power (gamma=0.5)');
subplot(2,2,4); imshow(hasil4); title('Stretch [30,180]');