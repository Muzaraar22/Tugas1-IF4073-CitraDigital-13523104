function app = ImageEnhancementApp()
% ImageEnhancementApp - GUI analisis dan perbaikan kualitas citra
%
%   Menyatukan analisis citra (histogram + fitur statistik) dan enhancement
%   dalam satu jendela. Citra masukan ditampilkan di kolom kiri beserta
%   histogram serta fiturnya, hasil enhancement di kolom kanan.
%
%   Alur pemakaian:
%       1. Pilih subfolder dataset dan citra, tekan "Muat Citra"
%       2. (Opsional) analisis otomatis tampil di kolom kiri
%       3. Pilih teknik enhancement dan isi parameternya
%       4. Tekan "Terapkan" - hasil muncul di kolom kanan
%       5. Tekan "Terapkan" lagi untuk menumpuk teknik (chaining)
%       6. "Reset" mengembalikan ke citra asli dan mengosongkan riwayat langkah
%       7. "Simpan Rekapan" menulis satu baris ke out/rekapan.csv
%
%   Semua teknik dijalankan lewat applyEnhancement, jadi aturan penanganan
%   warna dan validasi parameter konsisten dengan script batch.

% Semua logika berada di fungsi ini supaya mudah ditelusuri; komponen dibuat
% secara programatik (uifigure) supaya kode tetap berupa teks biasa yang mudah
% di-review, bukan file .mlapp biner.

addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'src')));
addpath(fullfile(fileparts(mfilename('fullpath')), 'gui'));

app = initApp();
end

% ===========================================================================
% Pembangunan UI
% ===========================================================================

function app = initApp()

% ---- struktur utama -------------------------------------------------------
% app dibuat sebagai handle class (AppState) supaya perubahan state di dalam
% callback tetap terlihat oleh pemanggil; kalau memakai struct biasa, MATLAB
% meneruskan struct secara by-value dan semua perubahan akan hilang.
app = AppState();

app.DatasetIdx = datasetIndex('dataset');
app.OutFolder  = 'out';

% placeholder panel parameter per teknik; diisi oleh buildIntensityPanel dkk
app.Panels = struct('intensity', [], 'equalization', [], ...
    'specification', [], 'filtering', []);

app.Figure = uifigure( ...
    'Name',             'Analisis dan Perbaikan Kualitas Citra - IF4073', ...
    'Position',         [80 40 1240 760], ...
    'Theme',            'light', ...
    'Color',            [0.94 0.94 0.94], ...
    'AutoResizeChildren', false, ...
    'CloseRequestFcn',  @(src, ~) closeApp(src, app));

% ---- divider position (normalized 0-1) ----
app.DividerPos = 0.27;  % 27% from left
app.IsDragging = false;

% ---- pembagian: panel kontrol kiri + area tampilan kanan ----
% Gunakan panel dengan posisi manual agar bisa di-resize dengan drag divider
app.LeftPanel  = uipanel(app.Figure, ...
    'Title', '', ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.96 0.96 0.96], ...
    'Units', 'normalized');

app.RightPanel = uipanel(app.Figure, ...
    'Title', '', ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'Units', 'normalized');

% ---- divider pemisah ----
app.Divider = uipanel(app.Figure, ...
    'Title', '', ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Units', 'normalized');

% Atur posisi awal panel dan divider
updatePanelPositions(app);

% ---- bangun isi panel kiri dan kanan ----
buildLeftPanel(app);
buildRightPanel(app);

setEmptyState(app);

% ---- setup mouse callbacks untuk drag divider ----
setupDividerCallbacks(app);

% figure dibuat visible setelah semua komponen siap supaya tidak berkedip
app.Figure.Visible = 'on';
end

% ---------------------------------------------------------------------------
function app = buildLeftPanel(app)

p = uigridlayout(app.LeftPanel, [7 1]);
p.RowHeight = {22, 26, 108, 30, 26, '1x', 26};
p.RowSpacing = 4;
p.Padding = [8 8 8 8];
p.BackgroundColor = [0.96 0.96 0.96];

% --- 1. pilih citra ---------------------------------------------------------
uilabel(p, 'Text', '1. PILIH CITRA', 'FontWeight', 'bold', ...
    'FontColor', [0.15 0.25 0.45]);

% Tambah "Dari File..." di awal dropdown
allFolderItems = ['Dari File...', {app.DatasetIdx.folder}];
app.FolderBox = uidropdown(p, ...
    'Items',     allFolderItems, ...
    'Value',     app.DatasetIdx(1).folder, ...
    'Tooltip',   'Pilih folder dataset atau buka file citra eksternal', ...
    'BackgroundColor', 'w');
app.FolderBox.ValueChangedFcn = @(~, ~) onFolderChanged(app);

app.ImageBox = uilistbox(p, ...
    'Items',     app.DatasetIdx(1).files, ...
    'Value',     app.DatasetIdx(1).files{1}, ...
    'Tooltip',   'Citra di subfolder terpilih');
app.ImageBox.ValueChangedFcn = @(~, ~) onImageSelected(app);
app.ImageBox.Multiselect = 'off';


loadRow = uigridlayout(p, [1 3]);
loadRow.ColumnWidth = {'1x', 150, 30};
loadRow.Padding = [0 0 0 0];
loadRow.BackgroundColor = [0.96 0.96 0.96];
uibutton(loadRow, 'Text', 'Muat Citra', ...
    'FontWeight', 'bold', ...
    'BackgroundColor', [0.30 0.50 0.75], ...
    'FontColor', 'w', ...
    'ButtonPushedFcn', @(~, ~) loadSelectedImage(app));
app.InfoLabel = uilabel(loadRow, 'Text', '', ...
    'HorizontalAlignment', 'left', 'FontSize', 10, ...
    'FontColor', [0.2 0.2 0.2]);
app.InfoLabel.Layout.Column = 2;

% --- 2. pilih teknik -------------------------------------------------------
uilabel(p, 'Text', '2. TEKNIK ENHANCEMENT', 'FontWeight', 'bold', ...
    'FontColor', [0.15 0.25 0.45]);

techRow = uigridlayout(p, [1 2]);
techRow.ColumnWidth = {'1x', 30};
techRow.Padding = [0 0 0 0];
techRow.BackgroundColor = [0.96 0.96 0.96];
app.TechBox = uidropdown(techRow, ...
    'Items', {'Intensity Transformation', ...
              'Histogram Equalization', ...
              'Histogram Specification / Matching', ...
              'Image Filtering'}, ...
    'Value', 'Intensity Transformation', ...
    'BackgroundColor', 'w');
app.TechBox.ValueChangedFcn = @(~, ~) onTechniqueChanged(app);

% Tombol info untuk menampilkan popup tentang teknik
app.InfoButton = uibutton(techRow, 'Text', 'i', ...
    'FontWeight', 'bold', ...
    'FontSize', 12, ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Tooltip', 'Klik untuk info teknik', ...
    'ButtonPushedFcn', @(~, ~) showTechniqueInfo(app));

% --- panel parameter per teknik (hanya satu terlihat) -----------------------
app.ParamStack = uigridlayout(p, [4 1]);
app.ParamStack.RowHeight = {'1x','1x','1x','1x'};
app.ParamStack.RowSpacing = 0;
app.ParamStack.Padding = [0 0 0 0];
app.ParamStack.BackgroundColor = [0.96 0.96 0.96];

app = buildIntensityPanel(app);
app = buildEqualizationPanel(app);
app = buildSpecificationPanel(app);
app = buildFilteringPanel(app);

% --- 3. aksi ---------------------------------------------------------------
actionRow = uigridlayout(p, [1 3]);
actionRow.ColumnWidth = {'1x','1x','1x'};
actionRow.ColumnSpacing = 6;
actionRow.Padding = [0 0 0 0];
actionRow.BackgroundColor = [0.96 0.96 0.96];

uibutton(actionRow, 'Text', 'Terapkan', ...
    'FontWeight', 'bold', ...
    'BackgroundColor', [0.20 0.55 0.35], ...
    'FontColor', 'w', ...
    'ButtonPushedFcn', @(~, ~) onApply(app));
uibutton(actionRow, 'Text', 'Reset', ...
    'BackgroundColor', [0.85 0.85 0.85], ...
    'ButtonPushedFcn', @(~, ~) onReset(app));
uibutton(actionRow, 'Text', 'Simpan Rekapan', ...
    'BackgroundColor', [0.95 0.85 0.55], ...
    'ButtonPushedFcn', @(~, ~) onSaveRecord(app));

% letakkan panel sesuai urutan row yang sudah ditentukan
app.FolderBox.Layout.Row = 2;
app.ImageBox.Layout.Row  = 3;
loadRow.Layout.Row      = 4;
techRow.Layout.Row      = 5;
app.ParamStack.Layout.Row = 6;
actionRow.Layout.Row    = 7;

onTechniqueChanged(app);
end

% ---------------------------------------------------------------------------
function app = buildIntensityPanel(app)

pnl = uipanel(app.ParamStack, 'Title', '', 'BorderType', 'line', ...
    'BackgroundColor', [0.99 0.99 0.99]);
pnl.Layout.Row = 1;
app.Panels.intensity = pnl;

g = uigridlayout(pnl, [4 2]);
g.RowHeight   = {22, 22, 22, 22};
g.ColumnWidth = {110, '1x'};
g.RowSpacing  = 3;
g.ColumnSpacing = 4;
g.Padding = [6 6 6 6];
g.BackgroundColor = [0.99 0.99 0.99];

uilabel(g, 'Text', 'Mode');
app.IntensityMode = uidropdown(g, ...
    'Items', {'negative', 'log', 'power', 'stretch'}, ...
    'Value', 'stretch', ...
    'BackgroundColor', 'w');
app.IntensityMode.ValueChangedFcn = @(~, ~) updateIntensityFields(app);

uilabel(g, 'Text', 'c (log / power)');
app.IntensityC = uieditfield(g, 'numeric', ...
    'Value', 1.0, 'LowerLimitInclusive', 0, ...
    'Tooltip', 'Skala transformasi. Kosongkan untuk pakai nilai otomatis pada mode log.');

uilabel(g, 'Text', 'gamma (power)');
app.IntensityGamma = uieditfield(g, 'numeric', 'Value', 1.0, ...
    'Tooltip', 'gamma < 1 mencerahkan, gamma > 1 menggelapkan');

uilabel(g, 'Text', 'r1, r2 (stretch)');
boundsRow = uigridlayout(g, [1 3]);
boundsRow.ColumnWidth = {'1x', '1x', 62};
boundsRow.Padding = [0 0 0 0];
boundsRow.BackgroundColor = [0.99 0.99 0.99];
app.IntensityR1 = uieditfield(boundsRow, 'numeric', 'Value', 0, ...
    'Tooltip', 'Batas bawah rentang yang akan dipetakan ke 0');
app.IntensityR2 = uieditfield(boundsRow, 'numeric', 'Value', 255, ...
    'Tooltip', 'Batas atas rentang yang akan dipetakan ke 255');
uibutton(boundsRow, 'Text', 'Ambil', 'FontSize', 9, ...
    'Tooltip', 'Isi r1 dan r2 dengan min/maks citra yang sedang dimuat', ...
    'ButtonPushedFcn', @(~, ~) onTakeBounds(app));

updateIntensityFields(app);
end

% ---------------------------------------------------------------------------
function app = buildEqualizationPanel(app)

pnl = uipanel(app.ParamStack, 'Title', '', 'BorderType', 'line', ...
    'BackgroundColor', [0.99 0.99 0.99]);
pnl.Layout.Row = 2;
app.Panels.equalization = pnl;

g = uigridlayout(pnl, [3 1]);
g.RowHeight = {22, 22, '1x'};
g.RowSpacing = 4;
g.Padding = [6 6 6 6];
g.BackgroundColor = [0.99 0.99 0.99];

uilabel(g, 'Text', 'Varian perataan histogram');
app.EqualVariant = uidropdown(g, ...
    'Items', {'lightness', 'rgb', 'grayscale'}, ...
    'Value', 'lightness', ...
    'BackgroundColor', 'w');

msg = uilabel(g, 'Text', {'', ...
    'lightness : perataan pada kanal L (Lab), warna tetap terjaga', ...
    'rgb        : perataan terpisah tiap kanal R,G,B, warna bisa bergeser', ...
    'grayscale  : hanya untuk citra abu-abu; pada citra berwarna otomatis'}, ...
    'FontSize', 9, 'FontColor', [0.3 0.3 0.3]);
msg.WordWrap = 'on';
end

% ---------------------------------------------------------------------------
function app = buildSpecificationPanel(app)

pnl = uipanel(app.ParamStack, 'Title', '', 'BorderType', 'line', ...
    'BackgroundColor', [0.99 0.99 0.99]);
pnl.Layout.Row = 3;
app.Panels.specification = pnl;

g = uigridlayout(pnl, [4 2]);
g.RowHeight   = {22, '1x', 26, 22};
g.ColumnWidth = {90, '1x'};
g.RowSpacing  = 3;
g.ColumnSpacing = 4;
g.Padding = [6 6 6 6];
g.BackgroundColor = [0.99 0.99 0.99];

uilabel(g, 'Text', 'Subfolder');
allRefFolders = ['Dari File...', {app.DatasetIdx.folder}];
app.RefFolderBox = uidropdown(g, ...
    'Items', allRefFolders, ...
    'Value', app.DatasetIdx(1).folder, ...
    'BackgroundColor', 'w');
app.RefFolderBox.ValueChangedFcn = @(~, ~) onRefFolderChanged(app);

uilabel(g, 'Text', 'Referensi');
app.RefImageBox = uilistbox(g, ...
    'Items', app.DatasetIdx(1).files, ...
    'Value', app.DatasetIdx(1).files{1});
app.RefImageBox.Multiselect = 'off';

% Baris 3: tombol-tombol
uibutton(g, 'Text', 'Pakai Citra Terpilih', ...
    'ButtonPushedFcn', @(~, ~) onUseReference(app));
uibutton(g, 'Text', 'Dari File...', ...
    'ButtonPushedFcn', @(~, ~) onOpenReferenceFile(app));

% Baris 4: status referensi
app.RefStatus = uilabel(g, 'Text', 'Belum ada citra referensi dipilih', ...
    'FontSize', 9, 'FontColor', [0.5 0.1 0.1]);
app.RefStatus.Layout.Row = 4;
app.RefStatus.Layout.Column = [1 2];
end

% ---------------------------------------------------------------------------
function app = buildFilteringPanel(app)

pnl = uipanel(app.ParamStack, 'Title', '', 'BorderType', 'line', ...
    'BackgroundColor', [0.99 0.99 0.99]);
pnl.Layout.Row = 4;
app.Panels.filtering = pnl;

g = uigridlayout(pnl, [4 2]);
g.RowHeight   = {22, 22, 22, '1x'};
g.ColumnWidth = {90, '1x'};
g.RowSpacing  = 3;
g.ColumnSpacing = 4;
g.Padding = [6 6 6 6];
g.BackgroundColor = [0.99 0.99 0.99];

uilabel(g, 'Text', 'Jenis');
app.FilterType = uidropdown(g, ...
    'Items', {'linear', 'median'}, 'Value', 'linear', ...
    'BackgroundColor', 'w');
app.FilterType.ValueChangedFcn = @(~, ~) updateFilteringFields(app);

uilabel(g, 'Text', 'Kernel');
app.KernelSource = uidropdown(g, ...
    'Items', {'gaussian', 'mean', 'sharpen', 'custom'}, ...
    'Value', 'gaussian', ...
    'BackgroundColor', 'w');
app.KernelSource.ValueChangedFcn = @(~, ~) updateFilteringFields(app);

uilabel(g, 'Text', 'Ukuran');
app.KernelSize = uidropdown(g, ...
    'Items', {'3', '5', '7', '9'}, 'Value', '3', ...
    'BackgroundColor', 'w');
app.KernelSize.ValueChangedFcn = @(~, ~) rebuildKernelGrid(app);

paramRow = uigridlayout(g, [1 2]);
paramRow.ColumnWidth = {'1x', '1x'};
paramRow.ColumnSpacing = 4;
paramRow.Padding = [0 0 0 0];
paramRow.BackgroundColor = [0.99 0.99 0.99];
app.FilterParam1 = uieditfield(paramRow, 'numeric', 'Value', 2.0, ...
    'Tooltip', 'Gaussian: sigma | Sharpen: bobot');
app.FilterParam2 = uieditfield(paramRow, 'numeric', 'Value', 15, ...
    'Tooltip', 'Median: ukuran window');

% tempat grid kernel kustom dibuat/dibangun ulang
app.KernelHost = uipanel(g, 'Title', 'Kernel kustom', 'BorderType', 'line', ...
    'BackgroundColor', 'w');
app.KernelHost.Layout.Row = 4;
app.KernelHost.Layout.Column = [1 2];
app.KernelLayout = uigridlayout(app.KernelHost, [1 1]);
app.KernelLayout.Padding = [2 2 2 2];
app.KernelLayout.BackgroundColor = 'w';

app = rebuildKernelGrid(app);
updateFilteringFields(app);
end

% ---------------------------------------------------------------------------
function app = buildRightPanel(app)

g = uigridlayout(app.RightPanel, [4 2]);
g.ColumnWidth = {'1x', '1x'};
g.RowHeight   = {'1x', '0.85x', '1x', 200};
g.RowSpacing  = 6;
g.ColumnSpacing = 6;
g.Padding = [0 0 0 0];
g.BackgroundColor = [0.94 0.94 0.94];

% baris 1: citra
app.ImageInPanel  = makeDisplayPanel(g, 'CITRA MASUKAN', 1, 1);
app.ImageOutPanel = makeDisplayPanel(g, 'CITRA HASIL',    1, 2);

% Gunakan axes biasa dengan posisi eksplisit agar mengisi panel
% Posisi [left bottom width height] - disesuaikan agar tidak overlap dengan panel title
app.AxImageIn = axes('Parent', app.ImageInPanel);
app.AxImageIn.Position = [0.02, 0.10, 0.96, 0.86];
app.AxImageIn.Visible = 'off';

app.AxImageOut = axes('Parent', app.ImageOutPanel);
app.AxImageOut.Position = [0.02, 0.10, 0.96, 0.86];
app.AxImageOut.Visible = 'off';

% baris 2: histogram grayscale
app.HistInPanel  = makeDisplayPanel(g, 'HISTOGRAM ABU-ABU - MASUKAN', 2, 1);
app.HistOutPanel = makeDisplayPanel(g, 'HISTOGRAM ABU-ABU - HASIL',    2, 2);
app.AxHistIn  = makeHistogramAxes(app.HistInPanel);
app.AxHistOut = makeHistogramAxes(app.HistOutPanel);

% baris 3: histogram per kanal
app.ChInPanel  = makeDisplayPanel(g, 'HISTOGRAM KANAL R,G,B - MASUKAN', 3, 1);
app.ChOutPanel = makeDisplayPanel(g, 'HISTOGRAM KANAL R,G,B - HASIL',    3, 2);
app.AxChIn  = makeChannelAxes(app.ChInPanel);
app.AxChOut = makeChannelAxes(app.ChOutPanel);

% baris 4: tabel fitur + catatan
app.StatsPanel = makeDisplayPanel(g, 'FITUR CITRA', 4, 1);
app.StatsTable = uitable(app.StatsPanel, ...
    'ColumnName', {'Fitur', 'Masukan', 'Hasil'}, ...
    'ColumnWidth', {'auto', 'auto', 'auto'}, ...
    'RowName', {}, ...
    'FontSize', 10, ...
    'BackgroundColor', 'w', ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1]);

app.LogPanel = makeDisplayPanel(g, 'METODE, PARAMETER & CATATAN', 4, 2);
inner = uigridlayout(app.LogPanel, [2 1]);
inner.RowHeight = {'1x', '2x'};
inner.RowSpacing = 4;
inner.Padding = [0 2 0 2];
inner.BackgroundColor = app.LogPanel.BackgroundColor;

app.LogText = uitextarea(inner, ...
    'Value', {'Belum ada langkah enhancement.'}, ...
    'Editable', 'off', 'FontSize', 10, ...
    'BackgroundColor', [1 1 1]);

app.NoteText = uitextarea(inner, ...
    'Value', {''}, 'Editable', 'on', 'FontSize', 10, ...
    'Placeholder', 'Catatan analisis: masalah kualitas visual yang terlihat dan alasan pemilihan metode...', ...
    'BackgroundColor', [1 1 1], 'Tooltip', 'Identifikasi singkat masalah citra + alasan metode (untuk laporan)');
end

% ---------------------------------------------------------------------------
function pnl = makeDisplayPanel(parent, title, row, col)
pnl = uipanel(parent, 'Title', title, 'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'BorderType', 'line', 'BackgroundColor', 'w');
pnl.Layout.Row = row;
pnl.Layout.Column = col;
end

% ---------------------------------------------------------------------------
function ax = makeHistogramAxes(parent)
lay = uigridlayout(parent, [1 1]);
lay.Padding = [2 2 2 2];
lay.BackgroundColor = 'w';
ax = uiaxes(lay);
ax.Layout.Row = 1;
ax.Layout.Column = 1;
end

function ax = makeChannelAxes(parent)
% tiga axes kecil untuk histogram kanal R, G, B di dalam satu panel
lay = uigridlayout(parent, [1 3]);
lay.ColumnWidth = {'1x', '1x', '1x'};
lay.ColumnSpacing = 2;
lay.Padding = [2 2 2 2];
lay.BackgroundColor = 'w';
ax = gobjects(1, 3);
ax(1) = uiaxes(lay); ax(1).Layout.Column = 1;
ax(2) = uiaxes(lay); ax(2).Layout.Column = 2;
ax(3) = uiaxes(lay); ax(3).Layout.Column = 3;
end

% ===========================================================================
% Callback
% ===========================================================================

function onFolderChanged(app)
folder = app.FolderBox.Value;

% Cek apakah "Dari File..." dipilih
if strcmp(folder, 'Dari File...')
    onOpenImageFile(app);
    return;
end

k = find(strcmp({app.DatasetIdx.folder}, folder), 1);
if isempty(k), return; end
app.ImageBox.Items = app.DatasetIdx(k).files;
app.ImageBox.Value = app.DatasetIdx(k).files{1};

% panel referensi ikut folder terpilih supaya gampang ganti referensi
app.RefFolderBox.Value = folder;
onRefFolderChanged(app);
end

function onOpenImageFile(app)
% Buka dialog untuk memilih citra dari file eksternal
[fileName, pathName] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', ...
    'File citra (*.png, *.jpg, *.bmp, *.tif)'; '*.*', 'Semua file'}, ...
    'Pilih citra');

if isequal(fileName, 0)
    % Jika dibatalkan, kembali ke folder default
    app.FolderBox.Value = app.DatasetIdx(1).folder;
    return;
end

try
    img = imread(fullfile(pathName, fileName));

    app.Original = img;
    app.Result   = [];
    app.Steps    = {};

    % Update info label
    app.InfoLabel.Text = sprintf('Eksternal: %s', fileName);

    app.LogText.Value = {'Citra dari file eksternal dimuat.'};
    app.NoteText.Value = {''};

    refreshAll(app);
catch ex
    uialert(app.Figure, sprintf('Gagal membaca citra:\n%s', ex.message), ...
        'Citra tidak bisa dimuat');
end
end

function onRefFolderChanged(app)
folder = app.RefFolderBox.Value;

% Cek apakah "Dari File..." dipilih
if strcmp(folder, 'Dari File...')
    onOpenReferenceFile(app);
    return;
end

k = find(strcmp({app.DatasetIdx.folder}, folder), 1);
if isempty(k), return; end
app.RefImageBox.Items = app.DatasetIdx(k).files;
app.RefImageBox.Value = app.RefImageBox.Items{1};
end

function onImageSelected(~)
% seleksi listbox tidak langsung memuat; pengguna tekan "Muat Citra"
end

function loadSelectedImage(app)
folder = app.FolderBox.Value;
file   = app.ImageBox.Value;
k = find(strcmp({app.DatasetIdx.folder}, folder), 1);
if isempty(k)
    uialert(app.Figure, 'Subfolder dataset tidak dikenali.', 'Citra tidak bisa dimuat');
    return;
end

try
    img = imread(fullfile(app.DatasetIdx(k).path, file));
catch ex
    uialert(app.Figure, sprintf('Gagal membaca citra:\\n%s', ex.message), ...
        'Citra tidak bisa dimuat');
    return;
end

app.Original = img;
app.Result   = [];
app.Steps    = {};

% baris kanal histogram hanya relevan untuk citra berwarna
isColor = (size(img, 3) == 3);
app.ChInPanel.Visible  = isColor;
app.ChOutPanel.Visible = isColor;
setRowVisible(app.ChInPanel.Parent, 3, isColor);
setRowVisible(app.ChOutPanel.Parent, 3, isColor);

if isColor
    app.InfoLabel.Text = sprintf('RGB %dx%d', size(img, 1), size(img, 2));
else
    app.InfoLabel.Text = sprintf('Abu-abu %dx%d', size(img, 1), size(img, 2));
end

app.LogText.Value = {'Belum ada langkah enhancement. Citra masukan sudah dimuat.'};
app.NoteText.Value = {''};

refreshAll(app);
end

function onTechniqueChanged(app)
tech = app.TechBox.Value;

app.Panels.intensity.Visible       = strcmp(tech, 'Intensity Transformation');
app.Panels.equalization.Visible    = strcmp(tech, 'Histogram Equalization');
app.Panels.specification.Visible   = strcmp(tech, 'Histogram Specification / Matching');
app.Panels.filtering.Visible       = strcmp(tech, 'Image Filtering');

% tampilkan field yang relevan untuk teknik terpilih
updateIntensityFields(app);
updateFilteringFields(app);
end

function showTechniqueInfo(app)
% Tampilkan popup dengan info tentang teknik yang dipilih
tech = app.TechBox.Value;
info = techniqueTooltip(tech);

% Ekstrak judul teknik
switch tech
    case 'Intensity Transformation'
        title = 'Intensity Transformation';
    case 'Histogram Equalization'
        title = 'Histogram Equalization';
    case 'Histogram Specification / Matching'
        title = 'Histogram Specification / Matching';
    case 'Image Filtering'
        title = 'Image Filtering';
end

% Tampilkan dialog info
uiconfirm(app.Figure, info, title, ...
    'Options', {'OK'}, ...
    'Icon', 'info');
end

function updateIntensityFields(app)
if ~isfield(app, 'IntensityMode') || isempty(app.IntensityMode)
    return;
end
mode = app.IntensityMode.Value;
isLog    = strcmp(mode, 'log');
isPower  = strcmp(mode, 'power');
isStretch = strcmp(mode, 'stretch');

app.IntensityC.Enable        = logical(isLog || isPower);
app.IntensityGamma.Enable    = isPower;
app.IntensityR1.Enable       = isStretch;
app.IntensityR2.Enable       = isStretch;

if isPower && app.IntensityGamma.Value == 1.0
    % beri nilai awal yang bermakna supaya tidak identik
    app.IntensityGamma.Value = 2.5;
end
end

function updateFilteringFields(app)
if ~isfield(app, 'FilterType') || isempty(app.FilterType)
    return;
end
jenis = app.FilterType.Value;
isLinear = strcmp(jenis, 'linear');
isMedian = strcmp(jenis, 'median');

app.KernelSource.Visible  = isLinear;
app.KernelSource.Enable   = isLinear;
app.KernelSize.Visible    = isLinear;
app.KernelSize.Enable     = isLinear;
app.FilterParam1.Visible  = isLinear && ~strcmp(app.KernelSource.Value, 'custom');
app.FilterParam1.Enable  = isLinear && ~strcmp(app.KernelSource.Value, 'custom');
app.FilterParam2.Visible  = isMedian;
app.FilterParam2.Enable   = isMedian;
app.KernelHost.Visible    = isLinear && strcmp(app.KernelSource.Value, 'custom');

src = app.KernelSource.Value;
if isLinear
    switch src
        case 'gaussian'
            app.FilterParam1.Tooltip = 'Sigma distribusi Gaussian';
        case 'sharpen'
            app.FilterParam1.Tooltip = 'Bobot sharpen';
        otherwise
            app.FilterParam1.Tooltip = 'Parameter';
    end
end
end

function app = rebuildKernelGrid(app)
% hapus isi panel lama karena uigridlayout butuh parent yang kosong
if ~isempty(app.KernelHost.Children)
    delete(app.KernelHost.Children);
end

n = str2double(app.KernelSize.Value);
if isempty(n) || mod(n, 2) == 0
    n = 3;
end

% Hitung ukuran sel agar muat di panel
% Gunakan drawnow agar layout selesai dihitung dulu
drawnow;
pause(0.01);  % beri waktu untuk layout update

% Ambil ukuran panel dalam pixel
panelPos = app.KernelHost.InnerPosition;
availableW = panelPos(3) - 20;  % kurangi padding
availableH = panelPos(4) - 20;    % kurangi padding

% Hitung ukuran sel agar muat, dengan batas min/max
maxCellSize = 60;
minCellSize = 25;

% Pilih ukuran yang muat untuk lebar dan tinggi, lalu ambil yang lebih kecil
cellFromWidth = floor(availableW / n);
cellFromHeight = floor(availableH / n);
cellSize = min(cellFromWidth, cellFromHeight);

% Terapkan batas
cellSize = max(minCellSize, min(maxCellSize, cellSize));

app.KernelLayout = uigridlayout(app.KernelHost, [n n]);
app.KernelLayout.RowHeight = repmat({cellSize}, 1, n);
app.KernelLayout.ColumnWidth = repmat({cellSize}, 1, n);
app.KernelLayout.RowSpacing = 1;
app.KernelLayout.ColumnSpacing = 1;
app.KernelLayout.Padding = [2 2 2 2];
app.KernelLayout.BackgroundColor = 'w';

app.KernelFields = buildKernelGrid(app.KernelLayout, n);
end

function onTakeBounds(app)
if isempty(app.Original)
    uialert(app.Figure, 'Muat citra dulu sebelum mengambil min/maks.', ...
        'Citra belum dimuat');
    return;
end
mn = double(min(app.Original(:)));
mx = double(max(app.Original(:)));
app.IntensityR1.Value = mn;
app.IntensityR2.Value = mx;
end

function onUseReference(app)
folder = app.RefFolderBox.Value;
file   = app.RefImageBox.Value;
k = find(strcmp({app.DatasetIdx.folder}, folder), 1);
if isempty(k), return; end

try
    app.Reference = imread(fullfile(app.DatasetIdx(k).path, file));
    app.RefStatus.Text = sprintf('Referensi: %s / %s', folder, file);
    app.RefStatus.FontColor = [0.2 0.5 0.2];
catch ex
    uialert(app.Figure, sprintf('Gagal membaca citra referensi:\\n%s', ex.message), ...
        'Referensi tidak bisa dimuat');
end
end

function onOpenReferenceFile(app)
[fileName, pathName] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', ...
    'File citra (*.png, *.jpg, *.bmp, *.tif)'; '*.*', 'Semua file'}, ...
    'Pilih citra referensi');

if isequal(fileName, 0), return; end   % pengguna membatalkan

try
    app.Reference = imread(fullfile(pathName, fileName));
    app.RefStatus.Text = sprintf('Referensi: %s (file eksternal)', fileName);
    app.RefStatus.FontColor = [0.2 0.5 0.2];
catch ex
    uialert(app.Figure, sprintf('Gagal membaca citra referensi:\\n%s', ex.message), ...
        'Referensi tidak bisa dimuat');
end
end

function onApply(app)
if isempty(app.Original)
    uialert(app.Figure, 'Muat citra dulu sebelum menerapkan enhancement.', ...
        'Citra belum dimuat');
    return;
end

try
    [tech, params] = collectInputs(app);
catch ex
    uialert(app.Figure, ex.message, 'Parameter belum lengkap');
    return;
end

% chaining: langkah berikutnya memakai hasil sebelumnya
base = app.Result;
if isempty(base)
    base = app.Original;
end

try
    [result, methodName, paramText] = applyEnhancement(base, tech, params);
catch ex
    uialert(app.Figure, sprintf('%s\\n\\n%s', ex.message, ...
        'Perbaiki parameter lalu tekan Terapkan lagi.'), 'Enhancement gagal');
    return;
end

app.Result = result;
app.Steps{end + 1} = sprintf('%s | %s', methodName, paramText);

app.LogText.Value = [{'Langkah enhancement yang sudah diterapkan:'}, ...
                     app.Steps];
refreshAll(app);
end

function onReset(app)
app.Result = [];
app.Steps  = {};
app.LogText.Value = {'Belum ada langkah enhancement. Citra dikembalikan ke masukan.'};
refreshAll(app);
end

function onSaveRecord(app)
if isempty(app.Original)
    uialert(app.Figure, 'Muat citra dulu sebelum menyimpan rekapan.', ...
        'Citra belum dimuat');
    return;
end

try
    rec = buildRecord(app);
    writeCsv(app, rec);
    app.RefStatus.FontColor = [0.2 0.5 0.2];
    uialert(app.Figure, sprintf('Rekapan disimpan ke:\\n%s', ...
        fullfile(app.OutFolder, 'rekapan.csv')), 'Tersimpan', 'Icon', 'success');
catch ex
    uialert(app.Figure, sprintf('%s\\n\\n%s', ex.message, ...
        'Periksa folder tujuan dan hak tulis.'), 'Rekapan gagal disimpan');
end
end

function closeApp(fig, app)
delete(fig);
delete(app.Reference);
app.Original = [];
app.Result   = [];
end

% ===========================================================================
% Pembacaan input & penyegaran tampilan
% ===========================================================================

function [tech, params] = collectInputs(app)

switch app.TechBox.Value
    case 'Intensity Transformation'
        tech = 'intensity';
        params = struct( ...
            'mode',  app.IntensityMode.Value, ...
            'c',     app.IntensityC.Value, ...
            'gamma', app.IntensityGamma.Value, ...
            'r1',    app.IntensityR1.Value, ...
            'r2',    app.IntensityR2.Value);

    case 'Histogram Equalization'
        tech = 'equalization';
        params = struct('variant', app.EqualVariant.Value);

    case 'Histogram Specification / Matching'
        tech = 'specification';
        params = struct('reference', app.Reference);

    case 'Image Filtering'
        tech = 'filtering';
        params = struct();

        if strcmp(app.FilterType.Value, 'median')
            params.jenis      = 'median';
            params.windowSize = app.FilterParam2.Value;
        else
            params.jenis        = 'linear';
            params.kernelSource = app.KernelSource.Value;
            params.kernelSize   = str2double(app.KernelSize.Value);

            switch app.KernelSource.Value
                case 'gaussian'
                    params.sigma = app.FilterParam1.Value;
                case 'sharpen'
                    params.sharpWeight = app.FilterParam1.Value;
                case 'custom'
                    params.kernel          = readKernelGrid(app.KernelFields);
                    params.normalizeKernel = true;
            end
        end

    otherwise
        error('applyEnhancement:teknikTidakDikenal', ...
            'Teknik tidak dikenal: %s', app.TechBox.Value);
end
end

function refreshAll(app)
drawInputColumn(app);
drawOutputColumn(app);
updateStatsTable(app);
end

function drawInputColumn(app)
if isempty(app.Original)
    clearAxes(app.AxImageIn);  clearAxes(app.AxHistIn);
    clearAxes(app.AxChIn);
    return;
end

isColor = (size(app.Original, 3) == 3);
drawImageAndHistograms( ...
    app.AxImageIn, app.AxHistIn, pickChannels(app.AxChIn, isColor), ...
    app.Original, 'masukan', [0.25 0.25 0.25]);

% judul grayscale di kolom masukan haris sama dengan kolom hasil
title(app.AxHistIn, 'Histogram Abu-abu - Masukan');
end

function drawOutputColumn(app)
if isempty(app.Result)
    clearAxes(app.AxImageOut); clearAxes(app.AxHistOut); clearAxes(app.AxChOut);
    title(app.AxHistOut, 'Histogram Abu-abu - Hasil');
    return;
end

isColor = (size(app.Result, 3) == 3);
drawImageAndHistograms( ...
    app.AxImageOut, app.AxHistOut, pickChannels(app.AxChOut, isColor), ...
    app.Result, 'hasil', [0.25 0.25 0.25]);
title(app.AxHistOut, 'Histogram Abu-abu - Hasil');
end

function ax = pickChannels(allAxes, isColor)
if isColor
    ax = allAxes;
else
    ax = [];
end
end

function updateStatsTable(app)
if isempty(app.Original)
    app.StatsTable.Data = {};
    app.StatsTable.ColumnName = {'Fitur', 'Masukan', 'Hasil'};
    return;
end

statsBefore = imageStatistics(app.Original);

if isempty(app.Result)
    colHasil = repmat({'-'}, 6, 1);
else
    statsAfter   = imageStatistics(app.Result);
    entropyAfter = statsAfter.entropy;

    if statsBefore.isColor
        colHasil = { ...
            num2str(statsAfter.grayscale.min), ...
            num2str(statsAfter.grayscale.max), ...
            sprintf('%.2f', statsAfter.grayscale.mean), ...
            sprintf('%.2f', statsAfter.grayscale.std), ...
            sprintf('%.4f', entropyAfter), ...
            sprintf('%d,%d,%d', statsAfter.channels(1).min, ...
                    statsAfter.channels(2).min, statsAfter.channels(3).min)};
    else
        colHasil = { ...
            num2str(statsAfter.grayscale.min), ...
            num2str(statsAfter.grayscale.max), ...
            sprintf('%.2f', statsAfter.grayscale.mean), ...
            sprintf('%.2f', statsAfter.grayscale.std), ...
            sprintf('%.4f', entropyAfter), ...
            '-'};
    end
end

sb = statsBefore;
colMasukan = { ...
    num2str(sb.grayscale.min), ...
    num2str(sb.grayscale.max), ...
    sprintf('%.2f', sb.grayscale.mean), ...
    sprintf('%.2f', sb.grayscale.std), ...
    sprintf('%.4f', sb.entropy)};

if sb.isColor
    colMasukan{end + 1} = sprintf('%d,%d,%d', ...
        sb.channels(1).min, sb.channels(2).min, sb.channels(3).min);
else
    colMasukan{end + 1} = '-';
    if numel(colHasil) == 6, colHasil{end} = '-'; else, colHasil{6} = '-'; end
end

names = {'Min intensitas', 'Maks intensitas', 'Rerata', ...
         'Simpangan baku', 'Entropi (bit)', 'Min per kanal R,G,B'};

app.StatsTable.ColumnName = {'Fitur', 'Masukan', 'Hasil'};
app.StatsTable.Data = [names(:), colMasukan(:), colHasil(:)];
end

function setEmptyState(app)
app.Original = [];
app.Result   = [];
app.Steps    = {};

if isfield(app, 'LogText') && ~isempty(app.LogText)
    app.LogText.Value = {'Muat citra dulu, lalu pilih teknik enhancement.'};
    app.StatsTable.Data = {};
    clearAxes(app.AxImageIn);  clearAxes(app.AxHistIn);  clearAxes(app.AxChIn);
    clearAxes(app.AxImageOut); clearAxes(app.AxHistOut); clearAxes(app.AxChOut);
    setRowVisible(app.ChInPanel.Parent, 3, false);
    setRowVisible(app.ChOutPanel.Parent, 3, false);
end
end

function setRowVisible(grid, row, visible)
if ~visible
    grid.RowHeight{row} = 1;
else
    grid.RowHeight{row} = '1x';
end
end

function clearAxes(ax)
if isempty(ax), return; end
if isgraphics(ax)
    cla(ax);
    axis(ax, 'off');
end
end

% ===========================================================================
% Rekaman (untuk laporan)
% ===========================================================================

function rec = buildRecord(app)
[tech, params] = collectInputs(app);

if ~isempty(app.Result)
    try
        [~, methodName, paramText] = applyEnhancement( ...
            app.Result, tech, params);
    catch
        methodName = '';
        paramText  = '';
    end
else
    methodName = '(belum dijalankan)';
    paramText  = '(belum dijalankan)';
end

folder = app.FolderBox.Value;
k = find(strcmp({app.DatasetIdx.folder}, folder), 1);

rec = struct();
rec.waktu   = char(datetime("now", 'Format', 'yyyy-MM-dd HH:mm:ss'));
rec.folder  = folder;
rec.file    = app.ImageBox.Value;
rec.teknik  = tech;
rec.metode  = methodName;
rec.param   = paramText;

sb = imageStatistics(app.Original);
rec.minSebelum   = sb.grayscale.min;
rec.maksSebelum  = sb.grayscale.max;
rec.rerataSebelum= sb.grayscale.mean;
rec.stdSebelum   = sb.grayscale.std;
rec.entroSebelum = sb.entropy;

if ~isempty(app.Result)
    sa = imageStatistics(app.Result);
    rec.minSesudah   = sa.grayscale.min;
    rec.maksSesudah  = sa.grayscale.max;
    rec.rerataSesudah= sa.grayscale.mean;
    rec.stdSesudah   = sa.grayscale.std;
    rec.entroSesudah = sa.entropy;
else
    rec.minSesudah   = '';
    rec.maksSesudah  = '';
    rec.rerataSesudah= '';
    rec.stdSesudah   = '';
    rec.entroSesudah = '';
end

rec.jumlahLangkah = numel(app.Steps);
rec.langkah       = strjoin(app.Steps, ' ; ');
rec.catatan       = app.NoteText.Value{1};
rec.path          = '';
if ~isempty(k)
    rec.path = fullfile(app.DatasetIdx(k).path, app.ImageBox.Value);
end
end

function writeCsv(app, rec)
if ~isfolder(app.OutFolder)
    mkdir(app.OutFolder);
end

csvPath = fullfile(app.OutFolder, 'rekapan.csv');

header = {'waktu','folder','file','path','teknik','metode','parameter', ...
          'jumlahLangkah','langkah', ...
          'minSebelum','maksSebelum','rerataSebelum','stdSebelum','entroSebelum', ...
          'minSesudah','maksSesudah','rerataSesudah','stdSesudah','entroSesudah', ...
          'catatan'};

row = {rec.waktu, rec.folder, rec.file, rec.path, rec.teknik, rec.metode, rec.param, ...
       num2str(rec.jumlahLangkah), rec.langkah, ...
       fmtNum(rec.minSebelum), fmtNum(rec.maksSebelum), ...
       fmtNum(rec.rerataSebelum), fmtNum(rec.stdSebelum), fmtNum(rec.entroSebelum), ...
       fmtNum(rec.minSesudah), fmtNum(rec.maksSesudah), ...
       fmtNum(rec.rerataSesudah), fmtNum(rec.stdSesudah), fmtNum(rec.entroSesudah), ...
       rec.catatan};

appendRecordCsv(csvPath, header, row);
end

function s = fmtNum(v)
if isempty(v)
    s = '';
elseif isnumeric(v)
    s = sprintf('%.4f', v);
else
    s = char(v);
end
end

function tip = techniqueTooltip(tech)
switch tech
    case 'Intensity Transformation'
        tip = 'Perbaikan intensitas: negative, log, power (gamma), atau contrast stretching.';
    case 'Histogram Equalization'
        tip = 'Meratakan histogram agar kontras lebih optimal.';
    case 'Histogram Specification / Matching'
        tip = 'Menyesuaikan histogram citra dengan citra referensi.';
    case 'Image Filtering'
        tip = 'Filter linear (konvolusi) atau non-linear (median).';
    otherwise
        tip = '';
end
end

% ===========================================================================
% Draggable Divider
% ===========================================================================

function updatePanelPositions(app)
% Perbarui posisi panel kiri, kanan, dan divider berdasarkan DividerPos
    figPos = app.Figure.Position;
    margin = 8 / figPos(3);  % margin dalam normalized units
    dividerWidth = 6 / figPos(3);  % lebar divider dalam normalized units
    gap = 4 / figPos(3);  % gap antar panel dan divider

    divX = app.DividerPos;

    % Left panel: dari kiri ke sebelum divider
    app.LeftPanel.Position = [margin, margin, divX - margin - gap - dividerWidth, 1 - 2*margin];

    % Divider: tepat di posisi divider
    app.Divider.Position = [divX - dividerWidth/2, 0, dividerWidth, 1];

    % Right panel: dari setelah divider ke kanan
    app.RightPanel.Position = [divX + dividerWidth/2 + gap, margin, 1 - divX - dividerWidth/2 - gap - margin, 1 - 2*margin];
end

function setupDividerCallbacks(app)
% Setup mouse callbacks untuk drag divider
    app.Figure.WindowButtonDownFcn   = @(~, ~) onDividerMouseDown(app);
    app.Figure.WindowButtonMotionFcn  = @(~, ~) onDividerMouseMove(app);
    app.Figure.WindowButtonUpFcn      = @(~, ~) onDividerMouseUp(app);
    app.Figure.SizeChangedFcn         = @(~, ~) updatePanelPositions(app);
end

function onDividerMouseDown(app)
% Cek apakah klik mouse dekat dengan divider
    figPos = app.Figure.Position;
    mouseX = app.Figure.CurrentPoint(1);  % posisi X mouse dalam pixel
    dividerPixelX = figPos(3) * app.DividerPos;

    % Toleransi 10 pixel
    if abs(mouseX - dividerPixelX) < 10
        app.IsDragging = true;
        app.Figure.Pointer = 'left';  % cursor resize
    end
end

function onDividerMouseMove(app)
% Update posisi divider saat dragging
    if app.IsDragging
        figPos = app.Figure.Position;
        mouseX = app.Figure.CurrentPoint(1);

        % Konversi ke posisi normalized
        newPos = mouseX / figPos(3);

        % Batasi: minimum 15%, maksimum 60%
        newPos = max(0.15, min(0.60, newPos));

        app.DividerPos = newPos;
        updatePanelPositions(app);
    else
        % Highlight divider saat hover
        figPos = app.Figure.Position;
        mouseX = app.Figure.CurrentPoint(1);
        dividerPixelX = figPos(3) * app.DividerPos;

        if abs(mouseX - dividerPixelX) < 10
            app.Figure.Pointer = 'left';
        else
            app.Figure.Pointer = 'arrow';
        end
    end
end

function onDividerMouseUp(app)
% Selesai dragging
    app.IsDragging = false;
    app.Figure.Pointer = 'arrow';
end



