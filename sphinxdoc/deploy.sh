
make clean
make html
rm -rf ../docs/*
mkdir -p ../docs
cp -r build/html/* ../docs/
