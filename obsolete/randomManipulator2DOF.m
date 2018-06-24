% Obtain an observation of the 6-DOF manipulator distribution with given radius of the interval
%
%
% [m,robotFeature] = randomManipulator6DOF(distribution, R, opt) returns
% a robot object m with its vector form robotFeature given sampling
% distribution, radius of interval R if the distribution is uniform, and
% other options.
%
%
% Code tested on MATLAB R2017b. Usage independent from other functions is not recommended.
%
% Used by:: dataGenScopeSubspace, dataGenWSsubspace
%
% Dependency:: RTB
%
% Reference::
% @book{CorkeRobotics,
% Author = {Peter I. Corke},
% Note = {ISBN 978-3-319-54413-7},
% Edition = {Second},
% Publisher = {Springer},
% Title = {Robotics, Vision \& Control: Fundamental Algorithms in {MATLAB}},
% Year = {2017}}
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

function [m,robotFeature] = randomManipulator2DOF(distribution, R)

        switch distribution
            case "uniform"
                D=[rand()*R rand()*R rand()*R rand()*R rand()*R rand()*R];
                A=[rand()*R rand()*R rand()*R rand()*R rand()*R rand()*R];
                alpha=[rand()*R rand()*R rand()*R rand()*R rand()*R rand()*R];
            case "normal"
                D=[randn() randn() randn() randn() randn() randn()];  
                A=[randn() randn() randn() randn() randn() randn()];  
                alpha=[randn() randn() randn() randn() randn() randn()];        
            otherwise
                D=[rand()*R rand()*R rand()*R rand()*R rand()*R rand()*R];
                A=[rand()*R rand()*R rand()*R rand()*R rand()*R rand()*R];
                alpha=[rand()*R rand()*R rand()*R rand()*R rand()*R rand()*R];
                warning("Distribution not recognized. Using default distribution. (uniform)");
        end
        mass=[];
        R=[];
        l=[];
        I=[];
        B=[];
        Tc=[];
        G=[];
        Jm=[];
        
        for t=1:6
    mass(t)=10*rand;
    R(t,:)=-0.1*rand(1,3)+0.05*ones(1,3);
    
    l(t,:)=rand(1,3);
    I(:,:,t)=diag(l(t,:));
    
    
    B(t)=0.005*rand;
    
    Tc(t,:)=[0.5*rand,-0.5*rand];
    
     G(t)=-100*rand+50;
     Jm(t)=5e-4*rand;
        end
     l1=Link([0 D(1) A(1) alpha(1)]);
        l2=Link([0 D(2) A(2) alpha(2)]);
        l3=Link([0 D(3) A(3) alpha(3)]);
        l4=Link([0 D(4) A(4) alpha(4)]);
        l5=Link([0 D(5) A(5) alpha(5)]);
        l6=Link([0 D(6) A(6) alpha(6)]);
        
        
        l1.m=mass(1);
        l1.R=R(1,:);
        l1.I=I(:,:,1);
        l1.B=B(1);
        l1.Tc=Tc(1,:);
        l1.G=G(1);
        l1.Jm=Jm(1);
        
        l2.m=mass(2);
        l2.R=R(2,:);
        l2.I=I(:,:,2);
        l2.B=B(2);
        l2.Tc=Tc(2,:);
        l2.G=G(2);
        l2.Jm=Jm(2);
        
        l3.m=mass(3);
        l3.R=R(3,:);
        l3.I=I(:,:,3);
        l3.B=B(3);
        l3.Tc=Tc(3,:);
        l3.G=G(3);
        l3.Jm=Jm(3);
        
        l4.m=mass(4);
        l4.R=R(4,:);
        l4.I=I(:,:,4);
        l4.B=B(4);
        l4.Tc=Tc(4,:);
        l4.G=G(4);
        l4.Jm=Jm(4);
        
        l5.m=mass(5);
        l5.R=R(5,:);
        l5.I=I(:,:,5);
        l5.B=B(5);
        l5.Tc=Tc(5,:);
        l5.G=G(5);
        l5.Jm=Jm(5);
        
        l6.m=mass(6);
        l6.R=R(6,:);
        l6.I=I(:,:,6);
        l6.B=B(6);
        l6.Tc=Tc(6,:);
        l6.G=G(6);
        l6.Jm=Jm(6);
        
        
        m=SerialLink([l1,l2,l3,l4,l5,l6]);
        robotFeature=[D,A,alpha,mass,reshape(R,1,[]),reshape(l,1,[]),B,reshape(Tc,1,[]),G,Jm];
    
end