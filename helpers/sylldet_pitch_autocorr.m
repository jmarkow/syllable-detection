function [PITCH,T]=sylldet_pitch_autocorr(AUDIO,FS,varargin)
%  pitch detection based on fft of autocorr

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

len=20;
overlap=10;
max_lag=20;
filtering=1200;

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
	end
end

max_lag=min(max_lag,len);

[b,a]=ellip(4,.2,40,[filtering]/(FS/2),'low');
AUDIO=filtfilt(b,a,AUDIO);

len=round((len/1e3)*FS);
overlap=round((overlap/1e3)*FS);
max_lag=round((max_lag/1e3)*FS);

step_size=len-overlap;

[nsamples]=length(AUDIO);

steps=1:step_size:nsamples-len;
nsteps=length(steps)
PITCH=zeros(nsteps,1);

T=(steps+len/2)/FS;

nfft=2^nextpow2(2*max_lag+1)
freq_vec=linspace(0,1,nfft/2+1)*FS/2;

for i=1:nsteps

	datawin=AUDIO(steps(i):steps(i)+len);
	[tmp,lags]=xcorr(datawin,[-max_lag max_lag]);
	[~,locs]=findpeaks(tmp);
	tmp_fft=log(abs(fft(tmp,nfft)));
	tmp_fft=tmp_fft(1:nfft/2+1);
	
	[~,loc]=max(tmp_fft);
	PITCH(i)=freq_vec(loc);

end

