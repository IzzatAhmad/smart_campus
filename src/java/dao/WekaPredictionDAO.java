package dao;

import util.DBConnection;
import weka.classifiers.trees.J48;
import weka.clusterers.SimpleKMeans;
import weka.classifiers.functions.SimpleLinearRegression;
import weka.core.*;

import java.sql.*;
import java.util.*;

/**
 * WekaPredictionDAO
 * Three WEKA models using only weka.jar (no external dependencies):
 *   1. SimpleLinearRegression — predict next month summons volume
 *   2. J48 Decision Tree      — student risk classification (HIGH/MEDIUM/LOW)
 *   3. SimpleKMeans           — offense hotspot zone detection
 */
public class WekaPredictionDAO {

    // =========================================================================
    // MODEL 1: SimpleLinearRegression — Next Month Summons Forecast
    // =========================================================================
    public double predictNextMonthSummons() {
        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT YEAR(summons_date) AS yr, MONTH(summons_date) AS mo, " +
                "       COUNT(*) AS total " +
                "FROM summons " +
                "GROUP BY yr, mo " +
                "ORDER BY yr, mo";

            List<double[]> rows = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new double[]{ rows.size() + 1.0, rs.getDouble("total") });
                }
            }

            if (rows.size() < 3) return -1;

            ArrayList<Attribute> attrs = new ArrayList<>();
            attrs.add(new Attribute("monthIndex"));
            attrs.add(new Attribute("summons"));

            Instances dataset = new Instances("monthlySummons", attrs, rows.size());
            dataset.setClassIndex(1);

            for (double[] row : rows) {
                Instance inst = new DenseInstance(2);
                inst.setValue(0, row[0]);
                inst.setValue(1, row[1]);
                dataset.add(inst);
            }

            SimpleLinearRegression slr = new SimpleLinearRegression();
            slr.buildClassifier(dataset);

            Instance next = new DenseInstance(2);
            next.setValue(0, rows.size() + 1.0);
            next.setValue(1, 0);
            next.setDataset(dataset);

            double prediction = slr.classifyInstance(next);
            return Math.max(0, Math.round(prediction));

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    // =========================================================================
    // MODEL 2: J48 Decision Tree — Student Risk Classification
    // =========================================================================
    public Map<String, String> classifyStudentRisk() {
        Map<String, String> riskMap = new LinkedHashMap<>();
        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT s.student_id, " +
                "       COUNT(sm.summons_id)                                            AS total_summons, " +
                "       SUM(CASE WHEN sm.status = 'UNPAID'  THEN 1 ELSE 0 END)         AS unpaid, " +
                "       SUM(CASE WHEN sm.status = 'PAID'    THEN 1 ELSE 0 END)         AS paid, " +
                "       SUM(CASE WHEN sm.status = 'OVERDUE' THEN 1 ELSE 0 END)         AS overdue, " +
                "       SUM(CASE WHEN sm.summons_type = 'MISCONDUCT' THEN 1 ELSE 0 END) AS misconduct " +
                "FROM student s " +
                "LEFT JOIN summons sm ON s.matric_no = sm.matric_no " +
                "GROUP BY s.student_id " +
                "HAVING total_summons > 0";

            List<String>   studentIds = new ArrayList<>();
            List<double[]> features   = new ArrayList<>();

            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    studentIds.add(rs.getString("student_id"));
                    features.add(new double[]{
                        rs.getDouble("total_summons"),
                        rs.getDouble("unpaid"),
                        rs.getDouble("paid"),
                        rs.getDouble("overdue"),
                        rs.getDouble("misconduct")
                    });
                }
            }

            if (features.isEmpty()) return riskMap;

            ArrayList<Attribute> attrs = new ArrayList<>();
            attrs.add(new Attribute("total_summons"));
            attrs.add(new Attribute("unpaid"));
            attrs.add(new Attribute("paid"));
            attrs.add(new Attribute("overdue"));
            attrs.add(new Attribute("misconduct"));

            List<String> riskLevels = Arrays.asList("LOW", "MEDIUM", "HIGH");
            attrs.add(new Attribute("risk", riskLevels));

            Instances dataset = new Instances("studentRisk", attrs, features.size());
            dataset.setClassIndex(5);

            for (double[] f : features) {
                double total = f[0], unpaid = f[1], overdue = f[3];
                String label = (total >= 5 || unpaid >= 3 || overdue >= 1) ? "HIGH"
                             : (total >= 2 || unpaid >= 1)                  ? "MEDIUM"
                             :                                                 "LOW";

                Instance inst = new DenseInstance(6);
                for (int i = 0; i < 5; i++) inst.setValue(i, f[i]);
                inst.setValue(5, riskLevels.indexOf(label));
                inst.setDataset(dataset);
                dataset.add(inst);
            }

            J48 tree = new J48();
            tree.setUnpruned(true);
            tree.buildClassifier(dataset);

            for (int i = 0; i < studentIds.size(); i++) {
                int classIdx = (int) tree.classifyInstance(dataset.get(i));
                riskMap.put(studentIds.get(i), riskLevels.get(classIdx));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return riskMap;
    }

    // =========================================================================
    // MODEL 3: SimpleKMeans — Offense Hotspot Zone Detection
    // FIX: Use clusterInstance() instead of getAssignments() which
    //      does not exist in WEKA 3.8.x
    // =========================================================================
    public List<Map<String, String>> detectHotspotClusters() {
        List<Map<String, String>> result = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT location, COUNT(*) AS cnt " +
                "FROM summons " +
                "WHERE location IS NOT NULL AND TRIM(location) != '' " +
                "GROUP BY location " +
                "ORDER BY cnt DESC";

            List<String>  locations = new ArrayList<>();
            List<Integer> counts    = new ArrayList<>();

            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    locations.add(rs.getString("location"));
                    counts.add(rs.getInt("cnt"));
                }
            }

            if (locations.isEmpty()) return result;

            // Build WEKA dataset — single numeric feature: offense count
            ArrayList<Attribute> attrs = new ArrayList<>();
            attrs.add(new Attribute("count"));

            Instances dataset = new Instances("hotspots", attrs, locations.size());
            for (int cnt : counts) {
                Instance inst = new DenseInstance(1);
                inst.setValue(0, (double) cnt);
                dataset.add(inst);
            }

            // Train SimpleKMeans — k = min(3, number of distinct locations)
            int k = Math.min(3, locations.size());
            SimpleKMeans kmeans = new SimpleKMeans();
            kmeans.setNumClusters(k);
            kmeans.setSeed(42);
            kmeans.buildClusterer(dataset);

            // ── FIX: use clusterInstance() per instance ──────────────────
            // getAssignments() does not exist in WEKA 3.8 standalone jar.
            // clusterInstance() is available in all WEKA versions.
            int[] assignments = new int[locations.size()];
            for (int i = 0; i < dataset.numInstances(); i++) {
                assignments[i] = kmeans.clusterInstance(dataset.get(i));
            }

            // Rank clusters by centroid value — highest centroid = HOT ZONE
            double[] centroids = new double[k];
            for (int c = 0; c < k; c++) {
                centroids[c] = kmeans.getClusterCentroids().get(c).value(0);
            }

            // Sort cluster indices: highest centroid first
            Integer[] order = new Integer[k];
            for (int i = 0; i < k; i++) order[i] = i;
            Arrays.sort(order, (a, b) -> Double.compare(centroids[b], centroids[a]));

            // Map each cluster index to a zone label
            String[] zoneLabels = {"HOT ZONE", "MODERATE ZONE", "LOW ZONE"};
            Map<Integer, String> zoneMap = new HashMap<>();
            for (int rank = 0; rank < k; rank++) {
                zoneMap.put(order[rank], zoneLabels[rank]);
            }

            // Build result list
            for (int i = 0; i < locations.size(); i++) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("location", locations.get(i));
                row.put("count",    String.valueOf(counts.get(i)));
                row.put("cluster",  zoneMap.getOrDefault(assignments[i], "LOW ZONE"));
                result.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}