function SNR=sylldet_eval_filter_snr(FILTERED_DATA,TARGET,varargin)
%
%
%

% smooth data

thresholds=[];
jitter=1e3;

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'thresholds'
			thresholds=varargin{i+1};
		case 'jitter'
			jitter=varargin{i+1};
	end
end

[nsamples,ntrials]=size(FILTERED_DATA);

TARGET=TARGET-jitter:TARGET+jitter;
NONTARGET=setdiff(1:nsamples,TARGET);

hitdata=FILTERED_DATA(TARGET,:);
missdata=FILTERED_DATA(NONTARGET,:);

SNR=std(hitdata)./std(missdata);


