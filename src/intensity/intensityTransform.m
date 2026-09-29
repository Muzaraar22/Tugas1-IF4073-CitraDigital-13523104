function result = intensityTransform(img, mode, param)
img = double(img);

%hasil = s, img = r kalau ngikutin ppt
switch lower(mode)
    case 'negative'
        result = 255 - img;

    case 'log'
        %memperdetail daerah gelap (mirip gamma < 1)
        if nargin < 3 || isempty(param) %cek var param
            c = 255 / log(1 + max(img(:))); %default biar max 255
        else
            c = param;
        end
        result = c * log(1 + img);

    case 'power'
        %gamma correction: param = [c, gamma]
        %gamma < 1 -> mencerahkan citra gelap
        %gamma > 1 -> menggelapkan citra terang
        c = param(1);
        gamma = param(2);
        result = c * (img / 255).^gamma * 255;

    case 'stretch'
        %contrast stretching linear: param = [rMin, rMax, sMin, sMax]
        %memetakan rentang input [rMin, rMax] jadi rentang target [sMin, sMax].
        rMin = param(1);
        rMax = param(2);
        sMin = param(3);
        sMax = param(4);
        result = (img - rMin) / (rMax - rMin) * (sMax - sMin) + sMin;

    otherwise
        error('P ga ada dipilihan: %s', mode);
end
%clip
result = clipToUint8(result);
end
