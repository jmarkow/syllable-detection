function [FILTERBANK DETECT PITCH FIG_NUM]=sylldet_prepare_filterbank(AUDIO,varargin)
% get pitch of sounds in a batch
%

ripple=.1;
attenuation=30;
cf=[476.5:476.5:953+476.5*6];
order=251;
in_band=[];
out_band=[];
trials=100;
in_bw=300;
out_bw=300;
in_stopband=300;
out_stopband=300;
smooth_tau=.01;
harm_number=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'ripple'
			ripple=varargin{i+1};
		case 'attenuation'
			attenuation=varargin{i+1};
		case 'cf'
			cf=varargin{i+1};
		case 'in_bw'
			in_bw=varargin{i+1};
		case 'out_bw'
			out_bw=varargin{i+1};
		case 'in_stopband'
			in_stopband=varargin{i+1};
		case 'out_stopband'
			out_stopband=varargin{i+1};
		case 'order'
			order=varargin{i+1};
		case 'in_band'
			in_band=varargin{i+1};
		case 'out_band'
			out_band=varargin{i+1};
		case 'trials'
			trials=varargin{i+1};
		case 'smooth_tau'
			smooth_tau=varargin{i+1};
		case 'harm_number'
			harm_number=varargin{i+1};
	end
end


nfilts=length(cf);


[nsamples,ntrials]=size(AUDIO.data);
smooth_smps=round(AUDIO.fs*smooth_tau);
smooth_filter=ones(1,smooth_smps)/smooth_smps;

if trials>=ntrials
	trials=ntrials-1;
end

trial_idx=(ntrials-trials):ntrials;

if isempty(in_band)
	in_band=2:2:nfilts;
	out_band=1:2:nfilts;
end

if isempty(harm_number)
	harm_number=1:length(in_band);
end

stopband=zeros(1,nfilts);
bw=zeros(1,nfilts);

stopband(in_band)=in_stopband;
stopband(out_band)=out_stopband;

bw(in_band)=in_bw;
bw(out_band)=out_bw;

[FILTERBANK.coeffs,FILTERBANK.freqz]=sylldet_filterbank(AUDIO.fs,'cf',cf,'stopband',stopband,'bw',bw,'order',order);
FILTERBANK.response=zeros(nsamples,length(trial_idx),nfilts);

[b,a]=ellip(5,.2,40,[300]/(AUDIO.fs/2),'high');

for i=1:nfilts
	FILTERBANK.response(:,:,i)=filter(FILTERBANK.coeffs(i),filtfilt(b,a,double(AUDIO.data(:,trial_idx))).^2);
end


DETECT.sig=sum(FILTERBANK.response(:,:,in_band).^2,3)./sum(FILTERBANK.response.^2,3);
DETECT.sig_smooth=filter(smooth_filter,1,DETECT.sig);
DETECT.t=[1:nsamples]/AUDIO.fs;

size(FILTERBANK.response)

PITCH.val=[];
PITCH.t=[];
for i=1:length(in_band)
	[PITCH.val(:,:,i),PITCH.t]=sylldet_pitch_batch(FILTERBANK.response(:,:,in_band(i)),...
		AUDIO.fs,'len',5,'overlap',0,'filtering',[]);
end


tmp=PITCH.val;

for i=1:length(in_band)
	tmp(:,:,i)=tmp(:,:,i)/harm_number(i);
end

PITCH.est=mean(tmp,3);
PITCH.est=squeeze(PITCH.est);
PITCH.est=interp1(PITCH.t,PITCH.est,DETECT.t);
PITCH.t=DETECT.t;
