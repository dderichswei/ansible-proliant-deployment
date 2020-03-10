FROM fedora:31

# Install Ansible Jupyter Kernel
RUN dnf install -y nginx sshpass git-all python3 python3-pip gcc python3-devel \
    bzip2 openssh openssh-clients python3-crypto python3-psutil glibc-locale-source && \
    localedef -c -i en_US -f UTF-8 en_US.UTF-8 && \
    pip install --no-cache-dir wheel psutil && \
    rm -rf /var/cache/yum

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

ENV NB_USER notebook
ENV NB_UID 1000
ENV HOME /home/${NB_USER}
ENV ANSIBLE_LIBRARY=${HOME}/hponeview/oneview-ansible/library
ENV ANSIBLE_MODULE_UTILS=${HOME}/hponeview/oneview-ansible/library/module_utils

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN echo "your web server is running.... (ddsynergy-container)" > /usr/share/nginx/html/index.html

RUN useradd \
    -c "Default user" \
	-d /home/notebook \
    -u ${NB_UID} \
    ${NB_USER}

#COPY . ${HOME}
USER root
RUN chown -R ${NB_USER} ${HOME}

USER notebook
RUN pip install --no-cache-dir --user ${NB_USER} requests-ftp
RUN pip install --no-cache-dir --user ${NB_USER} wrapt
RUN pip install --no-cache-dir --user ${NB_USER} lxml

RUN pip install --no-cache-dir --user ${NB_USER} jupyterlab
RUN pip install --no-cache-dir --user ${NB_USER} notebook

#RUN git clone https://github.com/ipython-contrib/jupyter_contrib_nbextensions.git
#RUN pip install --user ${NB_USER} -e jupyter_contrib_nbextensions

#RUN pip install --no-cache-dir ansible-jupyter-widgets
#RUN pip install --no-cache-dir ansible_kernel==0.9.0 && \
#    python -m ansible_kernel.install
RUN pip install --no-cache-dir --user ${NB_USER} ansible


RUN pip install --no-cache-dir --user ${NB_USER} bash_kernel
RUN python3 -m bash_kernel.install
RUN pip install --no-cache-dir --user ${NB_USER} hponeview
#RUN pip install --no-cache-dir --user ${NB_USER} hpICsp
RUN pip install --no-cache-dir --user ${NB_USER} python-hpilo
RUN pip install --no-cache-dir --user ${NB_USER} jupyter_contrib_nbextensions
RUN /home/notebook/.local/bin/jupyter nbextensions_configurator enable --user 
RUN /home/notebook/.local/bin/jupyter contrib nbextension install --user
RUN /home/notebook/.local/bin/jupyter nbextension enable toc2/main 
RUN /home/notebook/.local/bin/jupyter nbextension enable execute_time/ExecuteTime


RUN mkdir ${HOME}/hponeview
RUN mkdir ${HOME}/notebooks
RUN git -C ${HOME}/hponeview clone https://github.com/HewlettPackard/oneview-ansible.git
RUN chown -R ${NB_USER} ${HOME}/notebooks

#create ssh-keyfile
RUN ssh-keygen -b 2048 -t rsa -f /home/notebook/.ssh/id_rsa -N ""

USER ${NB_USER}
WORKDIR /home/notebook/notebooks
#CMD ["jupyter-notebook", "--ip", "0.0.0.0"]
CMD /home/notebook/.local/bin/jupyter-notebook --ip 0.0.0.0
EXPOSE 8888 80
