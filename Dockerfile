FROM openeuler/openeuler:23.03 as BUILDER
RUN dnf update -y && \
    dnf install -y golang && \
    go env -w GOPROXY=https://goproxy.cn,direct

MAINTAINER zengchen1024<chenzeng765@gmail.com>

# build binary
WORKDIR /go/src/github.com/opensourceways/robot-gitee-tech4dx-label
COPY . .
RUN GO111MODULE=on CGO_ENABLED=0 go build -a -o robot-gitee-tech4dx-label -buildmode=pie --ldflags "-s -linkmode 'external' -extldflags '-Wl,-z,now'" .

# copy binary config and utils
FROM openeuler/openeuler:22.03
RUN dnf -y update && \
    dnf in -y shadow && \
    dnf remove -y gdb-gdbserver && \
    groupadd -g 1000 tech4dx-label && \
    useradd -u 1000 -g tech4dx-label -s /sbin/nologin -m tech4dx-label && \
    echo > /etc/issue && echo > /etc/issue.net && echo > /etc/motd && \
    mkdir /home/tech4dx-label -p && \
    chmod 700 /home/tech4dx-label && \
    chown tech4dx-label:tech4dx-label /home/tech4dx-label && \
    echo 'set +o history' >> /root/.bashrc && \
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs && \
    rm -rf /tmp/*

USER tech4dx-label

WORKDIR /opt/app

COPY  --chown=tech4dx-label --from=BUILDER /go/src/github.com/opensourceways/robot-gitee-tech4dx-label/robot-gitee-tech4dx-label /opt/app/robot-gitee-tech4dx-label

RUN chmod 550 /opt/app/robot-gitee-tech4dx-label && \
    echo "umask 027" >> /home/tech4dx-label/.bashrc && \
    echo 'set +o history' >> /home/tech4dx-label/.bashrc

ENTRYPOINT ["/opt/app/robot-gitee-tech4dx-label"]
