img = imread(fullfile('citra_test_images_final','2. Kasus 1','image_02.png'));

img1Enh = intensityTransform(img, 'power', [1.13 3.8]);
viewHistogram(img, 'image_02');
viewHistogram(img1Enh, 'image_02 enhanced');
viewHistogram(intensityTransform(img, 'power', [1 3.8]), 'image_02 enhanced');
viewHistogram(histogramEqualizationRGB(img), 'p')

