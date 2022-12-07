FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libminizip-dev libexpat-dev
ADD . /xlsxio
WORKDIR /xlsxio
RUN cmake -DBUILD_EXAMPLES=ON -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN wget https://filesamples.com/samples/document/xlsx/sample3.xlsx
RUN wget https://filesamples.com/samples/document/xlsx/sample2.xlsx
RUN wget https://filesamples.com/samples/document/xlsx/sample1.xlsx
RUN wget https://file-examples.com/wp-content/uploads/2017/02/file_example_XLSX_10.xlsx
RUN wget https://file-examples.com/wp-content/uploads/2017/02/file_example_XLSX_5000.xlsx

FROM fuzzers/afl:2.52
COPY --from=builder /xlsxio/example_xlsxio_read /
COPY --from=builder /xlsxio/*.so /usr/local/lib/
COPY --from=builder /xlsxio/*.xlsx /testsuite/
# Find xlsxio shared objects and deps
COPY --from=builder /usr/lib/x86_64-linux-gnu/libminizip* /usr/local/lib/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libz* /usr/local/lib/
ENV LD_LIBRARY_PATH=/usr/local/lib/

ENTRYPOINT ["afl-fuzz", "-i", "/testsuite", "-o", "/xlsxioOut"]
CMD  ["/example_xlsxio_read", "@@"]
