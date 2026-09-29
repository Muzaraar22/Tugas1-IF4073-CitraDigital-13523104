function kernel = presetKernel(source, ukuran, param)
% presetKernel - kernel bawaan berukuran ukuran x ukuran untuk ditampilkan di grid GUI
%
% source : 'gaussian' | 'mean' | 'sharpen'
% ukuran : skalar ganjil
% param  : sigma (gaussian) atau bobot (sharpen); diabaikan untuk mean
%
% kernel : matriks ukuran x ukuran, atau [] kalau source/param tidak valid
%          (sharpen memakai Laplacian 3x3 yang sama seperti applyEnhancement,
%          diletakkan di tengah dan sisanya nol)

kernel = [];

switch lower(source)
    case 'gaussian'
        if isscalar(param) && isfinite(param) && param > 0
            kernel = gaussianKernel(ukuran, param);
        end

    case {'mean', 'box', 'averaging'}
        kernel = ones(ukuran, ukuran) / (ukuran * ukuran);

    case 'sharpen'
        if isscalar(param) && isfinite(param) && param >= 0
            c = (ukuran + 1) / 2;
            kernel = zeros(ukuran, ukuran);
            kernel(c, c)     = 1 + 4 * param;
            kernel(c - 1, c) = -param;
            kernel(c + 1, c) = -param;
            kernel(c, c - 1) = -param;
            kernel(c, c + 1) = -param;
        end
end
end
