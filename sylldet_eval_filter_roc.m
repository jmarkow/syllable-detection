function [STATS]=sylldet_eval_filter_roc(FILTERED_DATA,TARGET,varargin)
% Computes basic statitistics to evaluate filter performance
%
%[NEW_FILTER,TARGET_MATRIX]=sylldet_eval_filter_roc(FILTERED_DATA,TARGET,varargin)
%
%	FILTERED_DATA
%	nsamples x trials matrix of squared filter output
%
%	TARGET
%	nsamples
%
%	FS
%	sampling rate
%
%	The following may be passed as parameter/value pairs:
%
%		threshold
%		threshold for determining a match with template (normalized xcorr) (float, default:  .1)
%
%		step_size
%		step size for adaptive filter algorithm (float, default: .0008)
%
%		
%
%

%

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

% which thresholds to try?

thresholds=linspace(min(FILTERED_DATA(:)),max(FILTERED_DATA(:)),500);
nthresh=length(thresholds);

[nsamples,ntrials]=size(FILTERED_DATA);

TARGET=TARGET-jitter:TARGET+jitter;
TARGET(TARGET<1|TARGET>nsamples)=[];
nontarget=setdiff(1:nsamples,TARGET);

% how many trigger points are in the target range?

tp=zeros(1,nthresh);
tn=zeros(1,nthresh);

fp=zeros(1,nthresh);
fn=zeros(1,nthresh);

STATS.conf_mat=zeros(2,2,length(thresholds));
STATS.acc=zeros(1,length(thresholds));

for i=1:length(thresholds)

	idx=FILTERED_DATA>thresholds(i);

	[smps,trials]=find(idx(TARGET,:));

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
