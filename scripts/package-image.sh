package_image:
    runs-on: self-hosted
    needs: build_rootfs
    steps:
      - uses: actions/checkout@v3
        with:
          path: sfos-tissot-build

      - name: Download all artifacts
        uses: actions/download-artifact@v3
        with:
          pattern: "*"
          path: ${{ github.workspace }}/

      - name: Package final image
        run: bash sfos-tissot-build/scripts/package-image.sh
        env:
          IMAGE_DIR: ${{ github.workspace }}/images/
          OUTPUT_DIR: ${{ github.workspace }}/out/
