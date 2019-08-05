


mkdir -p ${E3_SRC_PATH}
pushd ${E3_SRC_PATH}

git clone https://github.com/icshwi/e3
pushd e3
bash e3_building_config.bash -y -t "${E3_PATH}" -b "${BASE}" -r "${REQUIRE}" -c "${TAG}" setup > /dev/null 2>&1
bash e3.bash gbase                      > /dev/null 2>&1
bash e3.bash ibase                      > /dev/null 2>&1
bash e3.bash bbase                      
bash e3.bash req
bash e3.bash -c mod
popd

popd

