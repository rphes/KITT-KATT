addpath(genpath('./tdoa-toolkit'));
global RecordData
global DeconvolutionMatrix

if (exist('DeconvolutionMatrix') ~= 1) || (isempty(DeconvolutionMatrix))
	try
		load('dmatrix.mat');   %I can't load this file
	catch
		display('dmatrix not found, will generate.');
    	Generation;
    end
end

if exist('PaWavSim') && (PaWavSim == 1)
    load pa-wav-sim/recorddata
end

