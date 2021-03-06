function [NEW_FILTER,TARGET_MATRIX]=sylldet_fir_learn(AUDIO,TARGET_SOUND,FS,varargin)
% Train adaptive filter to detected a particular target
% 
% [NEW_FILTER,TARGET_MATRIX]=sylldet_fir_learn(AUDIO,TARGET_SOUND,FS,varargin)
%
%	AUDIO
%	nsample x trials matrix of audio samples to train on
%
%	TARGET_SOUND
%	example of target sound
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
%		offset
%		offset for NLMS (float, default: 1e-9)
%
%		leakage
%		filter leakage (float, default: 1, no leakage)
%
%		order
%		number of filter coefficients (integer, default: 2e3)
%
%		offset_buffer
%		how far from offset to detect sound (in fraction of syllable length, default .2, i.e. 20% of syllable length from offset)
%
%		filt_type
%		training algorithm (string,default: 'nlms', options [n]lms, [l]ms, [r]ls, [b]lmsfft)
%
%		empty_trials
%		remove trials where no matches to template were foud (logical, default: 1)
%
%		block_size
%		block size for blmsfft algorithm (integer, default: 3)
%
%		jitter
%		n samples to the left and right of match to mark with 1 (integer, default: 5)
%
%		marker_jitter
%		n samples to the left and right of match idx to look for hits (integer, default: 600)
%
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

if ~isa(TARGET_SOUND,'double')
	TARGET_SOUND=double(TARGET_SOUND);
end

threshold=.1; % xcorr threshold for hits 
step_size=.0008; % learning step size
offset=1e-9; % nlms offset
leakage=1; % filter leakage
order=2000; % n coeffs
offset_buffer=0; %
filt_type='nlms'; % learning algorithm
empty_trials=1; % delete empty traisl? 
block_size=3; % block size (blmsfft only)
jitter=5; % jitter for marking hits
marker_jitter=600; % jitter for detecting hits
marker=[]; % where should a hit be?

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'threshold'
			threshold=varargin{i+1};
		case 'step_size'
			step_size=varargin{i+1};
		case 'offset'
			offset=varargin{i+1};
		case 'leakage'
			leakage=varargin{i+1};
		case 'order'
			order=varargin{i+1};
		case 'offset_buffer'
			offset_buffer=varargin{i+1};
		case 'marker'
			marker=varargin{i+1};
		case 'filt_type'
			filt_type=varargin{i+1};
		case 'block_size'
			block_size=varargin{i+1};
		case 'empty_trials'
			empty_trials=varargin{i+1};
		case 'jitter'
			jitter=varargin{i+1};
		case 'marker_jitter'
			marker_jitter=varargin{i+1};
	end
end

[nsamples,ntrials]=size(AUDIO);

template=flipud(zscore(TARGET_SOUND(:)));
norm_factor=template'*template;
template=template/norm_factor;

len=length(template);

disp('Creating target vector...');

TARGET_MATRIX=zeros(size(AUDIO));
todel=[];

score=filter(template,1,zscore(AUDIO));

for i=1:ntrials

	[vals,locs]=findpeaks(score(:,i),'minpeakheight',threshold,'minpeakdistance',round(.1*FS));
	
	if ~isempty(marker)
		flag1=locs<marker-marker_jitter;
		flag2=locs>marker+marker_jitter;
		to_del=flag1|flag2;
		vals(to_del)=[];
		locs(to_del)=[];
	end

	if isempty(vals)
		todel=[todel i];
		continue;
	end

	[sortvals,sortidx]=sort(vals(:),1,'descend');

	stoppoint=locs(sortidx(1));
	hitpoint=round(stoppoint-round(offset_buffer*len));

	hitpoints=hitpoint-jitter:hitpoint+jitter;
	hitpoints(hitpoints<1|hitpoints>nsamples)=[];

	TARGET_MATRIX(hitpoints,i)=1;

end

% convert to vector, columnwise

if empty_trials
	disp(['Deleting ' num2str(length(todel)) ' empty trials...']);
	TARGET_MATRIX(:,todel)=[];
	AUDIO(:,todel)=[];
	[nsamples,ntrials]=size(AUDIO);
end

disp('Learning filter (grab a coffee/beer, this may take a while)...');

switch lower(filt_type(1))

	case 'l'
		ha=adaptfilt.lms(order,step_size,leakage);

	case 'n'
		% so far most reliable, good tradeoff between performance and speed

		ha=adaptfilt.nlms(order,step_size,leakage,offset);

	case 'b'

		% great if you can use it, but seems highly unstable

		chop=mod(nsamples,block_size);
		AUDIO=AUDIO(1:end-chop,:);
		TARGET_MATRIX=TARGET_MATRIX(1:end-chop,:);

		order=2^nextpow2(order)-block_size;
		disp(['Setting order to ' num2str(order) '...']);	
		ha=adaptfilt.blmsfft(order,step_size,leakage,block_size);

	case 'r'

		% incredibly slow at higher order, unclear if we get a performance gain

		ha=adaptfilt.rls(order,leakage,std(AUDIO(:))*eye(order));

	otherwise

end

ha.PersistentMemory=true;

for i=1:ntrials
	disp(['Trial ' num2str(i) ]);
	[y,e]=filter(ha,AUDIO(:,i),TARGET_MATRIX(:,i));
end

NEW_FILTER=ha.coefficients;
