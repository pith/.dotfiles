# Init my go workspace
mkdir -p ~/dev/go/src
mkdir -p ~/dev/go/bin
mkdir -p ~/dev/go/pkg

# Go tools for emacs
go get -u github.com/kisielk/errcheck
go get -u github.com/nsf/gocode
go get -u code.google.com/p/rog-go/exp/cmd/godef
go get -u github.com/dougm/goflymake
go get -u github.com/golang/lint/golint
