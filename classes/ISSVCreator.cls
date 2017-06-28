/**
 *  ISSVCreator.cls
 *  @description Interface for Source System View data spwawning functionality
 *  @author Ernesto Valdes, Traction On Demand
 */
public interface ISSVCreator {

	ISSVCreator syncToCustomers();

	ISSVCreator spawnData();
}