function [PITCH,T]=sylldet_pitch_zcross(AUDIO,FS,varargin)
% zero-crossing based pitch detection
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

len=30;
overlap=29;
filtering=[600 1.25e3];

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
	 	case 'filtering'
			filtering=varargin{i+1};
	end
end

if ~isempty(filtering)
	[b,a]=ellip(4,.2,40,[filtering]/(FS/2),'bandpass');
	AUDIO=filtfilt(b,a,AUDIO);
end

len=round((len/1e3)*FS);
overlap=round((overlap/1e3)*FS);

step_size=len-overlap;

[nsamples]=length(AUDIO);

steps=1:step_size:nsamples-1-len;
nsteps=length(steps);
PITCH=zeros(nsteps,1);

T=(steps+len/2)/FS;

idx=1:length(AUDIO)-1;
idx2=idx+1;

norm_fact=.5*FS/len;

zero_cross=(AUDIO(idx)<0&AUDIO(idx2)>0)|(AUDIO(idx)>0&AUDIO(idx2)<0);

for i=1:nsteps
	
	datawin=zero_cross(steps(i):steps(i)+len);

	% number of zero crossings...
	
	PITCH(i)=sum(datawin)*norm_fact;
end
