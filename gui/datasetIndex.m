function index = datasetIndex(rootFolder)
% datasetIndex - membaca struktur folder citra uji resmi
%
% rootFolder : folder dataset (default 'dataset', relatif ke current folder)
% index      : struct array dengan field
%                .folder : nama subfolder (misal '2. Kasus 1')
%                .path   : path lengkap subfolder
%                .files  : cell array nama file citra PNG, terurut abjad
%
% Dipakai oleh GUI (untuk mengisi dropdown/listbox) dan oleh script batch,
% supaya penambahan citra di dataset langsung terbaca tanpa ubah kode.

if nargin < 1 || isempty(rootFolder)
    rootFolder = 'dataset';
end

if ~isfolder(rootFolder)
    error('datasetIndex:folderTidakDitemukan', ...
        'Folder dataset tidak ditemukan: %s', rootFolder);
end

dirs = dir(rootFolder);
dirs = dirs([dirs.isdir]);
dirs = dirs(~ismember({dirs.name}, {'.', '..'}));
[~, urutan] = sort({dirs.name});   % urutkan biar dropdown konsisten
dirs = dirs(urutan);

index = struct('folder', {}, 'path', {}, 'files', {});

for d = 1:numel(dirs)
    folderName = dirs(d).name;
    folderPath = fullfile(rootFolder, folderName);

    files = dir(fullfile(folderPath, '*.png'));
    [~, urutanFile] = sort({files.name});
    files = files(urutanFile);

    entry = struct();
    entry.folder = folderName;
    entry.path   = folderPath;
    entry.files  = {files.name};

    index(d) = entry;
end
end
