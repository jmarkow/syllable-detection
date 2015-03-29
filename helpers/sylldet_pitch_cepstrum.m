function [PITCH,T]=sylldet_pitch_autocorr(AUDIO,FS,varargin)
%  pitch detection based on fft of autocorr

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

len=20;
overlap=15;
filtering=[300 3e3];
range=[400 1500];
nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'len'
			len=varargin{i+1};
		case 'overlap'
			overlap=varargin{i+1};
		case 'max_lag'
			max_lag=varargin{i+1};
		case 'filtering'
			filtering=varargin{i+1};
		case 'range'
			range=varargin{i+1};
	end
end

[b,a]=ellip(4,.2,40,[filtering]/(FS/2),'bandpass');
AUDIO=filtfilt(b,a,AUDIO);

len=round((len/1e3)*FS);
overlap=round((overlap/1e3)*FS);

[s,f,T]=spectrogram(AUDIO,len,overlap,[],FS);

nsteps=size(s,2);
PITCH=zeros(nsteps,1);

s_c=real(ifft(log(abs(s))));
range_c=sort(round(FS./range));

[~,loc]=max(s_c(range_c(1):range_c(2),:));
PITCH=FS./((loc-1)+range_c(1));



