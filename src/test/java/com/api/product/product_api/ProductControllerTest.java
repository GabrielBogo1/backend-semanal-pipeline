package com.listadecompras.listacompras;

import com.listadecompras.listacompras.controller.ProductController;
import com.listadecompras.listacompras.entity.Product;
import com.listadecompras.listacompras.repository.ProductRepository;
import com.listadecompras.listacompras.service.ProductService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@ActiveProfiles("test")
public class ProductControllerTest {

    private MockMvc mockMvc;

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ProductService productService;

    @InjectMocks
    private ProductController productController;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(productController).build();
    }

    @Test
    void testCreateProductSuccess() throws Exception {
        Product product = new Product(null, "New Product","Obs");
        when(productService.save(any(Product.class))).thenReturn(product);

        mockMvc.perform(post("/api/product")
                        .contentType("application/json")
                        .content("{\"name\":\"New Product\",\"price\":150.0}"))
                .andExpect(status().isOk());
    }

    @Test
    void testCreateProductFailure() throws Exception {
        Product product = new Product(null, "New Product", "Obs");
        when(productService.save(any(Product.class)))
                .thenThrow(new DataIntegrityViolationException("Data Integrity Violation"));

        mockMvc.perform(post("/api/product")
                        .contentType("application/json")
                        .content("{\"name\":\"New Product\",\"price\":150.0}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testFindProductById() throws Exception {
        Product product = new Product(1L, "Product Name", "Obs");
        when(productRepository.findById(1L)).thenReturn(java.util.Optional.of(product));

        mockMvc.perform(get("/api/product/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.productName").value("Product Name"))
                .andExpect(jsonPath("$.productObservation").value("Obs"));
    }

}
