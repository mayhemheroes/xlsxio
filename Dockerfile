FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libminizip-dev libexpat-dev
RUN git clone https://github.com/brechtsanders/xlsxio.git
WORKDIR /xlsxio
RUN cmake -DBUILD_EXAMPLES=ON -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN mkdir /xlsxioCorpus
RUN wget https://filesamples.com/samples/document/xlsx/sample3.xlsx
RUN wget https://filesamples.com/samples/document/xlsx/sample2.xlsx
RUN wget https://filesamples.com/samples/document/xlsx/sample1.xlsx
RUN wget https://file-examples.com/wp-content/uploads/2017/02/file_example_XLSX_10.xlsx
RUN wget https://file-examples.com/wp-content/uploads/2017/02/file_example_XLSX_5000.xlsx
RUN mv *.xlsx /xlsxioCorpus

ENTRYPOINT ["afl-fuzz", "-i", "/xlsxioCorpus", "-o", "/xlsxioOut"]
CMD  ["/xlsxio/example_xlsxio_read", "@@"]
