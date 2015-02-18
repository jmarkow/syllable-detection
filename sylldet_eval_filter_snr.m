function SNR=sylldet_eval_filter_snr(FILTERED_DATA,TARGET,varargin)
%
%
%

% smooth data

thresholds=[];
padding=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'thresholds'
			thresholds=varargin{i+1};
		case 'padding'
			padding=varargin{i+1};
	end
end

[nsamples,ntrials]=size(FILTERED_DATA);

if ~isempty(padding)
	TARGET=[TARGET(1)-padding(1) TARGET(2)+padding(2)];
end

TARGET=TARGET(1):TARGET(2);
NONTARGET=setdiff(1:nsamples,TARGET);

hitdata=FILTERED_DATA(TARGET,:);
missdata=FILTERED_DATA(NONTARGET,:);


SNR=std(hitdata(:))./std(missdata(:));


