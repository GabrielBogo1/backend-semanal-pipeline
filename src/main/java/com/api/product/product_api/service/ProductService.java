package com.api.product.product_api.service;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.api.product.product_api.entity.Product;
import com.api.product.product_api.repository.ProductRepository;


@Service
public class ProductService {
       
    @Autowired
    ProductRepository productRepository;

    public Product save(Product product) {
            return productRepository.save(product);
        }

    public void updateProduct (final Long id, final Product product) {

        final Product productSaved = this.productRepository.findById(id).orElse(null);

        if (productSaved == null || !productSaved.getId().equals(id)) {
            throw new RuntimeException();
        }
        BeanUtils.copyProperties(product, productSaved);
        this.productRepository.save(productSaved);
    }

    public void deleteProduct (final Long id){
        final Product dataProduct = this.productRepository.findById(id).orElse(null);

        if (dataProduct == null || !dataProduct.getId().equals(id)){
            throw new RuntimeException();
        }

        assert dataProduct != null;
        this.productRepository.delete(dataProduct);
    }
}

