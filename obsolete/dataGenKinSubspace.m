%Training data generation for 6-DOF Serial-link manipulator constant orientation workspace with shoulder offset
%[resM, resB ] = data_Gen_6_DOF_R3 (n, entry, orientation) are the inputs
%and the outputs of a training set of n examples with scope defined by
%entry
%Author: Peiyuan (Alexander) Liao
%Dependency: MATLAB RTB
%calculation by binary maps
%6-DOF Spherical wrist with shoulder offset
%Constant Orientation Workspace
%\\Data Generation for Neural Network//
%
%
%
%BSD 3-Clause License
%
%Copyright (c) 2018, Alexander (Peiyuan) Liao
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are met:
%
%* Redistributions of source code must retain the above copyright notice, this
%  list of conditions and the following disclaimer.
%
%* Redistributions in binary form must reproduce the above copyright notice,
%  this list of conditions and the following disclaimer in the documentation
%  and/or other materials provided with the distribution.
%
%* Neither the name of the copyright holder nor the names of its
%  contributors may be used to endorse or promote products derived from
%  this software without specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [trainFeature, trainLabel] = dataGenKinSubspace(n, dim1, dim2, varargin)

    opt.parallel = true;
    
    opt.type = '6DOF';
    opt.workspace = 'R3';
        
    opt.sampleDist = 'uniform';
    opt.sampleRadius = 0.5;
    
    opt.fileType = '-v7.3';
    
    opt.ikine = 'numerical';
    opt.ilimit = 500;
    opt.rlimit = 100;
    opt.slimit = 100;
    opt.tol = 1e-10;
    opt.lambda = 0.1;
    opt.lambdamin = 0;
    opt.search = false;
    
    opt.tensor = false;
    
    opt.showcase = false;

    opt = tb_optparse(opt, varargin);
    
    r = opt.sampleRadius;

    if opt.showcase
        warning('Showing sample workspace of PUMA560. Other inputs will be overridden')
        n=1;
        dim1=[-1 1 -1 1 -1 1 .1 .1 .1];
        dim2=[0 0 0];
    end
    
    switch opt.fileType
        
        case '-v7.3'
        
        case '-v7'
            warning('The variable "trainLabel" might not be saved. If you are not sure if the training set will exceed the limit of other .mat file versions please use defalut (-v7.3) instead');
        
        case '-v6'
            warning('The variable "trainLabel" might not be saved. If you are not sure if the training set will exceed the limit of other .mat file versions please use defalut (-v7.3) instead');

        case '-v4'
            warning('The variable "trainLabel" might not be saved. If you are not sure if the training set will exceed the limit of other .mat file versions please use defalut (-v7.3) instead');

        otherwise
            warning('File version parsing failed. Using default instead. (-v7.3)');
    
    end

    
    xmin=dim1(1);
    xmax=dim1(2);
    ymin=dim1(3);
    ymax=dim1(4);
    zmin=dim1(5);
    zmax=dim1(6);
    deltaX=dim1(7);
    deltaY=dim1(8);
    deltaZ=dim1(9);
    scope=[xmin:deltaX:xmax,ymin:deltaY:ymax,zmin:deltaZ:zmax];
    
    H = coordinateCell(xmin,xmax,ymin,ymax,zmin,zmax,deltaX,deltaY,deltaZ);    
    P=zeros(size(H));
    [pX,pY,pZ]=size(P);    
    
    switch opt.type
        
        case '6DOF'  
            [m,robotFeature] = randomManipulator6DOF(opt.sampleDist, r, opt.showcase);
            P = bitTensor(m,P,H,opt,dim2);
            feature=[robotFeature,scope,dim2];
            
            trainFeature=zeros(n,max(size(feature)));
            
            trainFeature(1,:)=feature;

            if opt.tensor
                trainLabel=cell(1,n);
                trainLabel{1}=P;
            else
                [pX,pY,pZ]=size(P);
                trainLabel=zeros(n,pX*pY*pZ);
                trainLabel(1,:)=tens2vec(P);
            end
            
            if opt.parallel
                if opt.tensor
                    parfor i=2:n
                       [m,robotFeature] = randomManipulator6DOF(opt.sampleDist, r, opt.showcase);
                       Pnew = bitTensor(m,P,H,opt,dim2);
                       trainFeature(i,:)= [robotFeature,scope,dim2];
                       trainLabel{i}=Pnew;
                    end
                else
                    parfor i=2:n
                       [m,robotFeature] = randomManipulator6DOF(opt.sampleDist, r, opt.showcase);
                       Pnew = bitTensor(m,P,H,opt,dim2);
                       trainFeature(i,:)= [robotFeature,scope,dim2];                      
                       trainLabel(i,:)=tens2vec(Pnew);
                    end
                end
                
            else
                for i=2:n
                   [m,robotFeature] = randomManipulator6DOF(opt.sampleDist, r, opt.showcase);
                   P = bitTensor(m,P,H,opt,dim2);
                  
                   trainFeature(i,:)= [robotFeature,scope,dim2];
                   
                   if opt.tensor
                       trainLabel{i}=P;
                   else
                       trainLabel(i,:)=tens2vec(P);
                   end
                end              
            end
                     
        case '5DOF'
            [m,robotFeature] = randomManipulator5DOF(opt.sampleDist, r);
            P = bitTensor(m,P,H,opt.ikine,opt.workspace,dim2);
            if strcmp(opt.ikine,'analytic')              
                warning('Analytic form of inverse kinematics does not exist for underactuated kinematic structures. Calculations will be done using numerical method instead.');
                opt.ikine='numerical';
                P = bitTensor(P,H,opt.ikine,opt.workspace,dim2);
            end
            feature=[robotFeature,scope,dim2];
 
            trainFeature=zeros(n,max(size(feature)));
            
            trainFeature(1,:)=feature;

            if opt.tensor
                trainLabel=cell(1,n);
                trainLabel{1}=P;
            else
                trainLabel=zeros(n,pX*pY*pZ);
                trainLabel(1,:)=tens2vec(P);
            end
            
                       if opt.parallel
                if opt.tensor
                    parfor i=2:n
                       [m,robotFeature] = randomManipulator5DOF(opt.sampleDist, r, opt.showcase);
                       Pnew = bitTensor(m,P,H,opt,dim2);
                       trainFeature(i,:)= [robotFeature,scope,dim2];
                       trainLabel{i}=Pnew;
                    end
                else
                    parfor i=2:n
                       [m,robotFeature] = randomManipulator5DOF(opt.sampleDist, r, opt.showcase);
                       Pnew = bitTensor(m,P,H,opt,dim2);
                       trainFeature(i,:)= [robotFeature,scope,dim2];                      
                       trainLabel(i,:)=tens2vec(Pnew);
                    end
                end
                
            else
                for i=2:n
                   [m,robotFeature] = randomManipulator5DOF(opt.sampleDist, r, opt.showcase);
                   P = bitTensor(m,P,H,opt,dim2);
                  
                   trainFeature(i,:)= [robotFeature,scope,dim2];
                   
                   if opt.tensor
                       trainLabel{i}=P;
                   else
                       trainLabel(i,:)=tens2vec(P);
                   end
                end              
            end
                     
            
        otherwise
            error('Workspace parameter parsing failed.')
        
    end
         
    filename = horzcat(strcat(opt.type,opt.workspace),'n',num2str(n),'.','pt',num2str(pX),'.',num2str(pY),'.',num2str(pZ),'.',datestr(datetime('now'),'mm.dd.yy.HH.MM'),'.mat');
    %                   Type                         Number of Samples                                                               Date

    save(filename,'trainFeature','trainLabel',opt.fileType);
end