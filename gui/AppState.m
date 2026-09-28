classdef AppState < handle
% AppState - wadah state bersama untuk ImageEnhancementApp
%
%   Dibuat sebagai handle class supaya perubahan pada state (citra masukan,
%   citra hasil, riwayat langkah, handle komponen GUI) ikut terlihat oleh semua
%   callback. Kalau state disimpan di struct biasa, MATLAB meneruskan struct
%   secara by-value sehingga perubahan di dalam callback tidak pernah keluar.
%
%   Properti diisi bertahap saat UI dibangun: buildLeftPanel, buildIntensityPanel,
%   buildEqualizationPanel, buildSpecificationPanel, buildFilteringPanel, dan
%   buildRightPanel.

    properties
        % ---- state aplikasi ----
        Original   = [];    % citra masukan (immutable)
        Result     = [];    % citra hasil chaining ([] = belum ada)
        Reference  = [];    % citra referensi untuk specification
        Steps      = {};    % riwayat langkah: cell array of string
        DatasetIdx = [];    % struktur dataset dari datasetIndex()
        OutFolder  = 'out'; % tujuan rekapan CSV dan figure batch

        % ---- container utama ----
        Figure     = [];
        LeftPanel  = [];
        RightPanel = [];
        Divider    = [];    % panel pemisah yang bisa di-drag
        DividerPos = 0.27; % posisi divider (normalized 0-1, default 27%)
        IsDragging = false; % status dragging
    end

    properties
        % ---- panel kontrol kiri ----
        FolderBox  = []; ImageBox = []; InfoLabel = [];
        TechBox    = []; InfoButton = [];
        ParamStack = [];

        % pilih citra & teknik
        Panels     = [];

        % panel intensity
        IntensityMode   = []; IntensityC   = [];
        IntensityGamma  = []; IntensityR1  = []; IntensityR2 = [];

        % panel equalization
        EqualVariant = [];

        % panel specification
        RefFolderBox = []; RefImageBox = []; RefStatus = [];

        % panel filtering
        FilterType  = []; KernelSource = []; KernelSize = [];
        FilterParam1 = []; FilterParam2 = [];
        KernelHost  = []; KernelLayout = []; KernelFields = [];

        % panel tampilan kanan
        ImageInPanel  = []; ImageOutPanel  = [];
        AxImageIn     = []; AxImageOut     = [];
        HistInPanel   = []; HistOutPanel   = [];
        AxHistIn      = []; AxHistOut      = [];
        ChInPanel     = []; ChOutPanel     = [];
        AxChIn        = []; AxChOut        = []
        StatsPanel    = []; StatsTable     = []
        LogPanel      = []; LogText        = []; NoteText = []
    end
end
