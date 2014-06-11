addpath(genpath('./tdoa-toolkit'));
global RecordData

if ~exist('DeconvolutionMatrix')
    global DeconvolutionMatrix
    Generation;
end

if exist('PaWavSim') && (PaWavSim == 1)
    load pa-wav-sim/recorddata
end

