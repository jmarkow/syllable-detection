function [STATS]=sylldet_eval_filter_roc(FILTERED_DATA,TARGET,varargin)
%
%
%

% smooth data

nparams=length(varargin);
jitter=1e3;

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'jitter'
			jitter=varargin{i+1};
	end
end

thresholds=linspace(min(FILTERED_DATA(:)),max(FILTERED_DATA(:)),500);
nthresh=length(thresholds);

[nsamples,ntrials]=size(FILTERED_DATA);

TARGET=TARGET-jitter:TARGET+jitter;
nontarget=setdiff(1:nsamples,TARGET);

tp=zeros(1,nthresh);
tn=zeros(1,nthresh);

fp=zeros(1,nthresh);
fn=zeros(1,nthresh);

STATS.conf_mat=zeros(2,2,length(thresholds));
STATS.acc=zeros(1,length(thresholds));

for i=1:length(thresholds)

	idx=FILTERED_DATA>thresholds(i);

	[~,trials]=find(idx(TARGET,:));

	tp(i)=length(unique(trials));
	fn(i)=ntrials-tp(i);

	[~,trials]=find(idx(nontarget,:));

	fp(i)=length(unique(trials));
	tn(i)=ntrials-fp(i);

	STATS.conf_mat(1:2,1:2,i)=[ tp(i) fn(i) ; fp(i) tn(i) ]; 
	STATS.acc(i)=sum(diag(STATS.conf_mat(:,:,i)))/(ntrials*2);
end

STATS.thresholds=thresholds;

% optimal point, closest in Euclidean distance to [0,1]
